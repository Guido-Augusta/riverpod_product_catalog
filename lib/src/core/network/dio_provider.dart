import 'dart:async';

import 'package:dio/dio.dart';
import 'package:product_catalog_app/src/core/constants/api_endpoints.dart';
import 'package:product_catalog_app/src/core/constants/app_env.dart';
import 'package:product_catalog_app/src/core/storage/token_storage.dart';
import 'package:product_catalog_app/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  final options = BaseOptions(
    baseUrl: AppEnv.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  );

  final dio = Dio(options);

  Completer<String?>? refreshTokenCompleter;

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getAccessToken();
        if (token != null && !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            error.requestOptions.path != ApiEndpoints.login &&
            error.requestOptions.path != ApiEndpoints.refreshToken) {
          try {
            String? newAccessToken;
            // 1. If there is a refresh token process that is running, WAIT for the process to complete
            if (refreshTokenCompleter != null &&
                !refreshTokenCompleter!.isCompleted) {
              newAccessToken = await refreshTokenCompleter!.future;
            } else {
              // 2. If there is no refresh token process, LOCK and refresh
              refreshTokenCompleter = Completer<String?>();
              final refreshToken = await tokenStorage.getRefreshToken();
              if (refreshToken == null) {
                refreshTokenCompleter!.complete(null);
                await ref.read(authControllerProvider.notifier).logout();
                return handler.next(error);
              }
              final refreshDio = Dio(BaseOptions(baseUrl: AppEnv.baseUrl));
              final response = await refreshDio.post(
                ApiEndpoints.refreshToken,
                data: {'refreshToken': refreshToken},
              );
              newAccessToken = response.data['accessToken'] as String;
              final newRefreshToken = response.data['refreshToken'] as String;
              await tokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );
              // 3. Notify all other requests that are waiting that the new token is ready
              refreshTokenCompleter!.complete(newAccessToken);
            }
            // 4. If the new token is successfully obtained, repeat (retry) the failed request
            if (newAccessToken != null) {
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retryResponse = await dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          } catch (_) {
            if (refreshTokenCompleter != null &&
                !refreshTokenCompleter!.isCompleted) {
              refreshTokenCompleter!.complete(null);
            }
            await ref.read(authControllerProvider.notifier).logout();
          } finally {
            // Reset lock after done
            refreshTokenCompleter = null;
          }
        }
        return handler.next(error);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestHeader: false,
      responseHeader: false,
      requestBody: true,
      responseBody: true,
    ),
  );

  return dio;
}
