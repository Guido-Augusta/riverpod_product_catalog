import 'package:dio/dio.dart';
import 'package:product_catalog_app/src/core/constants/api_endpoints.dart';
import 'package:product_catalog_app/src/core/exceptions/app_exceptions.dart';
import 'package:product_catalog_app/src/core/network/dio_provider.dart';
import 'package:product_catalog_app/src/features/auth/data/models/auth_response_model.dart';
import 'package:product_catalog_app/src/features/auth/data/models/token_model.dart';
import 'package:product_catalog_app/src/features/auth/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponseModel> login({
    required String username,
    required String password,
    int expiresInMins = 1,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'username': username,
          'password': password,
          'expiresInMins': expiresInMins,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      throw Error.throwWithStackTrace(AppException.fromDioError(e), stackTrace);
    } catch (e, stackTrace) {
      throw Error.throwWithStackTrace(
        AppException.general(e.toString()),
        stackTrace,
      );
    }
  }

  Future<UserModel> getCurrentUser({required String accessToken}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.currentUser,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      throw Error.throwWithStackTrace(AppException.fromDioError(e), stackTrace);
    } catch (e, stackTrace) {
      throw Error.throwWithStackTrace(
        AppException.general(e.toString()),
        stackTrace,
      );
    }
  }

  Future<TokenModel> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken, 'expiresInMins': 60},
      );
      return TokenModel.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      throw Error.throwWithStackTrace(AppException.fromDioError(e), stackTrace);
    } catch (e, stackTrace) {
      throw Error.throwWithStackTrace(
        AppException.general(e.toString()),
        stackTrace,
      );
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(dioProvider));
}
