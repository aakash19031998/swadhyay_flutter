import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/employee_model.dart';
import 'auth_data_source.dart';

/// Real-backend implementation. Not used while
/// [AppConfig.useMockData] is `true`, but implemented in full so enabling a
/// live backend later is a one-line binding change.
class AuthRemoteDataSourceImpl implements AuthDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<EmployeeModel> login({required String employeeNumber, required String pin}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'employeeNumber': employeeNumber, 'pin': pin},
      );
      return EmployeeModel.fromJson(response.data!);
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
