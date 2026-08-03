import 'package:dartz/dartz.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../models/employee_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._secureStorage, this._localStorage);

  final AuthDataSource _dataSource;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  @override
  Future<Either<Failure, ({String message, EmployeeEntity employee})>> login({
    required String employeeNumber,
    required String pin,
  }) async {
    try {
      final ({String message, EmployeeModel employee}) result =
          await _dataSource.login(employeeNumber: employeeNumber, pin: pin);

      await _secureStorage.saveAuthToken(
        'session-${result.employee.empCode}-${DateTime.now().millisecondsSinceEpoch}',
      );
      await _localStorage.saveJson(StorageKeys.loggedInEmployee, result.employee.toJson());
      await _localStorage.setLoggedIn(true);

      return Right((message: result.message, employee: result.employee));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _dataSource.logout();
    } catch (_) {
      // Best-effort: the local session is cleared regardless so the user
      // is never stuck signed in on-device if the server call fails.
    }
    await _secureStorage.clear();
    await _localStorage.remove(StorageKeys.loggedInEmployee);
    await _localStorage.setLoggedIn(false);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dataSource.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<EmployeeEntity?> currentEmployee() async {
    final Map<String, dynamic>? json = _localStorage.readJson(StorageKeys.loggedInEmployee);
    if (json == null) return null;
    return EmployeeModel.fromJson(json);
  }
}
