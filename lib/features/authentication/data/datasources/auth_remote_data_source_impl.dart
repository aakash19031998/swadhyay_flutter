import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/employee_model.dart';
import 'auth_data_source.dart';

/// Real-backend implementation — the only [AuthDataSource] wired in by
/// [AuthDependencies]; Login, Logout, and Change Password always hit the
/// live backend, no mock option.
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
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      // `status` was originally documented as a JSON boolean, but a failed
      // login has been observed sending it as the string "False" instead
      // (the same bool-vs-string inconsistency hit on other endpoints) —
      // accept either form rather than assuming one and crashing.
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
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
  Future<({bool success, String message})> logout({required String empCd}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.logout,
        data: {'empCd': empCd},
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool success = (body['status'] as String?)?.toLowerCase() == 'true';
      final String message = body['message'] as String? ?? '';

      return (success: success, message: message);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'Unable to logout',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<({bool success, String message})> changePassword({
    required String empCd,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.changePassword,
        data: {
          'empCd': empCd,
          'oldPass': currentPassword,
          'newPass': newPassword,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool success = (body['status'] as String?)?.toLowerCase() == 'true';
      final String message = body['message'] as String? ?? '';

      return (success: success, message: message);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'Unable to change password',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
