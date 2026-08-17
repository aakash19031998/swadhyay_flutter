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

  /// `Logout`'s response has no separate error case for a rejected logout —
  /// it is a normal `"False"` status with its own message, so the result is
  /// returned as `(success, message)` instead of thrown, the same
  /// convention as [changePassword].
  Future<({bool success, String message})> logout({required String empCd});

  /// `ChangePasswordNew`'s response has no separate error/exception case for
  /// a wrong current password — it is a normal `"False"` status with its own
  /// message, so the result is returned as `(success, message)` instead of
  /// thrown, the same convention as `DummyAddBtnValidation`/
  /// `BagDoneWithFirstReceive`.
  Future<({bool success, String message})> changePassword({
    required String empCd,
    required String currentPassword,
    required String newPassword,
  });
}
