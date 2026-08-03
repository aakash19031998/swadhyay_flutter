import 'dart:io';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../error/exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'network_info.dart';

/// Thin wrapper around a configured [Dio] instance. Data sources depend on
/// this, never on `Dio` directly, so retry/timeout/interceptor policy stays
/// centralized.
///
/// Every method checks [NetworkInfo] before touching the network and throws
/// [NetworkException] when offline — deliberately *not* a [DioException], so
/// it skips every data source's `on DioException` mapping and surfaces
/// straight through each repository's existing `on NetworkException catch`
/// to [NetworkFailure], reusing the Failure/snackbar pipeline every
/// controller already has instead of adding a second one.
///
/// Every method also retries exactly once on a connection-level failure
/// (never on a real HTTP error response like a 4xx/5xx). This is what
/// actually fixes "the drawer works on first launch, then fails after the
/// app is backgrounded and resumed/relaunched": Android can silently kill
/// the OS-level TCP socket a pooled keep-alive HTTP connection was using
/// while the app was backgrounded, but Dio's `HttpClient` doesn't know
/// that yet — the first request made on that stale pooled connection after
/// resuming fails with a low-level connection error, and only *after* that
/// failure does the client evict it and open a fresh one. This has nothing
/// to do with cached data (nothing here is ever cached — every call below
/// still hits the network fresh, same as before); it's a dead-socket-reuse
/// issue, and retrying once transparently recovers from it.
class ApiClient {
  ApiClient(this._dio, this._networkInfo);

  final Dio _dio;
  final NetworkInfo _networkInfo;

  Dio get dio => _dio;

  static Dio buildDio({required AuthInterceptor authInterceptor}) {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.addAll([authInterceptor, LoggingInterceptor()]);
    return dio;
  }

  Future<void> _ensureConnected() async {
    if (!await _networkInfo.isConnected) throw const NetworkException();
  }

  bool _isStaleConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError || e.error is SocketException;
  }

  Future<Response<T>> _send<T>(Future<Response<T>> Function() request) async {
    await _ensureConnected();
    try {
      return await request();
    } on DioException catch (e) {
      if (!_isStaleConnectionError(e)) rethrow;
      return await request();
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _send(() => _dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _send(() => _dio.post<T>(path, data: data));
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _send(() => _dio.put<T>(path, data: data));
  }

  Future<Response<T>> delete<T>(String path, {dynamic data}) {
    return _send(() => _dio.delete<T>(path, data: data));
  }
}
