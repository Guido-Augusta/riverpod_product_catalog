import 'package:dio/dio.dart';

sealed class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;

  factory AppException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Connection timeout. Please try again.');

      case DioExceptionType.connectionError:
        return const NoInternetException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        // Safe extraction message dari backend
        String? serverMessage;
        if (data is Map<String, dynamic>) {
          serverMessage =
              data['message'] as String? ?? data['error'] as String?;
        }

        if (statusCode == 401) {
          return UnauthorizedException(
            serverMessage ?? 'Session has expired. Please log in again.',
          );
        } else if (statusCode == 404) {
          return NotFoundException(serverMessage ?? 'Data not found.');
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            serverMessage ?? 'Server error.',
            statusCode: statusCode,
          );
        }
        return ClientException(
          serverMessage ?? 'Request error.',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return const RequestCancelledException('Request cancelled.');

      case DioExceptionType.badCertificate:
        return const SecurityException('Invalid security certificate.');

      case DioExceptionType.unknown:
      default:
        return AppException.general(
          error.message ?? 'An unexpected error occurred.',
        );
    }
  }

  factory AppException.general(String message) = GeneralException;
}

class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

class NoInternetException extends AppException {
  const NoInternetException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class ClientException extends AppException {
  const ClientException(super.message, {super.statusCode});
}

class ParsingException extends AppException {
  const ParsingException([
    super.message = 'Failed to process data from server.',
  ]);
}

class RequestCancelledException extends AppException {
  const RequestCancelledException(super.message);
}

class SecurityException extends AppException {
  const SecurityException(super.message);
}

class GeneralException extends AppException {
  const GeneralException(super.message);
}
