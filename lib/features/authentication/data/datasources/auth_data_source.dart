import '../models/employee_model.dart';

/// Data-source contract with exactly two implementations:
/// [AuthMockDataSourceImpl] (V1, in-memory) and [AuthRemoteDataSourceImpl]
/// (real backend). [AuthRepositoryImpl] depends only on this interface, so
/// [AuthBinding] is the single place that decides which one is wired in.
abstract class AuthDataSource {
  Future<({String message, EmployeeModel employee})> login({
    required String employeeNumber,
    required String pin,
  });

  Future<void> logout();

  Future<void> changePassword({required String currentPassword, required String newPassword});
}
