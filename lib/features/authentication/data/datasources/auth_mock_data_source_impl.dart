import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/employee_model.dart';
import 'auth_data_source.dart';

/// In-memory V1 data source. Accepts a single demo employee so the app is
/// fully usable end-to-end before a backend exists.
class AuthMockDataSourceImpl implements AuthDataSource {
  static const String _demoEmployeeNumber = '11780';
  static const String _demoPin = '1234';

  @override
  Future<({String message, EmployeeModel employee})> login({
    required String employeeNumber,
    required String pin,
  }) async {
    await Future.delayed(AppConfig.mockLatency);

    if (employeeNumber != _demoEmployeeNumber || pin != _demoPin) {
      throw const ServerException(message: 'Invalid employee number or PIN');
    }

    return (
      message: 'Logged in',
      employee: EmployeeModel(
        empCode: _demoEmployeeNumber,
        name: 'Vikash Kumar D. Nishad',
        punchInAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(AppConfig.mockLatency);
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await Future.delayed(AppConfig.mockLatency);

    if (currentPassword.isEmpty) {
      throw const ServerException(message: 'Current password is incorrect');
    }
  }
}
