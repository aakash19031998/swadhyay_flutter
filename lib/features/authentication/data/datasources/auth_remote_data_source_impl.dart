import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/employee_model.dart';
import 'auth_data_source.dart';

/// Real-backend implementation. Wired in whenever
/// [AppConfig.useMockAuth] is `false` (the default) — see [AuthDependencies].
class AuthRemoteDataSourceImpl implements AuthDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({String message, EmployeeModel employee})> login({
    required String employeeNumber,
    required String pin,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.checkLogInNew,
        data: {
          'empCd': employeeNumber,
          'empPass': pin,
          'appVersion': AppConfig.appVersion,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool status = body['status'] as bool? ?? false;
      final String message = body['message'] as String? ?? 'Login failed';

      if (!status) {
        throw ServerException(message: message, statusCode: response.statusCode);
      }

      final Map<String, dynamic>? data = body['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ServerException(message: 'Malformed login response');
      }

      return (message: message, employee: EmployeeModel.fromApiJson(data));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'Login failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post<void>(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw ServerException(message: 'Logout failed', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _apiClient.post<void>(
        ApiEndpoints.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'Unable to change password',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
