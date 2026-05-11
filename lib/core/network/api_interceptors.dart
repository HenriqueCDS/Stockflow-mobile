// Migrado de: src/api/api.js (interceptors.response)
// Axios interceptor → Dio InterceptorsWrapper
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../errors/failures.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: dioErrorToFailure(err),
        type: err.type,
        response: err.response,
      ),
    );
  }
}

Failure dioErrorToFailure(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout) {
    return const NetworkFailure();
  }
  final code = e.response?.statusCode;
  if (code == 401) return const UnauthorizedFailure();
  if (code == 404) {
    final msg = e.response?.data is Map
        ? e.response!.data['message'] ?? 'Recurso não encontrado.'
        : 'Recurso não encontrado.';
    return NotFoundFailure(msg as String);
  }
  final msg = e.response?.data is Map
      ? e.response!.data['message'] ?? 'Erro no servidor.'
      : 'Erro no servidor.';
  return ServerFailure(msg as String, statusCode: code);
}
