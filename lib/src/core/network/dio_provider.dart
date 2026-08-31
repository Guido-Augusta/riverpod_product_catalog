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
          final refreshToken = await tokenStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: AppEnv.baseUrl));
              final response = await refreshDio.post(
                ApiEndpoints.refreshToken,
                data: {'refreshToken': refreshToken},
              );

              final newAccessToken = response.data['accessToken'] as String;
              final newRefreshToken = response.data['refreshToken'] as String;

              await tokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retryResponse = await dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } catch (_) {
              await ref.read(authControllerProvider.notifier).logout();
            }
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
