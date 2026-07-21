import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Thin wrapper around a configured [Dio] instance. Data sources depend on
/// this, never on `Dio` directly, so retry/timeout/interceptor policy stays
/// centralized.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

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

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data}) {
    return _dio.delete<T>(path, data: data);
  }
}
