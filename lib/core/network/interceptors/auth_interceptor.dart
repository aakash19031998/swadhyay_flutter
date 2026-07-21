import 'package:dio/dio.dart';

import '../../storage/secure_storage_service.dart';

/// Attaches the bearer token to every outgoing request and flags a 401 so
/// the caller can react (e.g. force logout) without every repository having
/// to special-case authentication itself.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage, {this.onUnauthorized});

  final SecureStorageService _secureStorage;
  final Future<void> Function()? onUnauthorized;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final String? token = await _secureStorage.readAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && onUnauthorized != null) {
      await onUnauthorized!.call();
    }
    handler.next(err);
  }
}
