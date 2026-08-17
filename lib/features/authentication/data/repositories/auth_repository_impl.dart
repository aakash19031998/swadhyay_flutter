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
  Future<Either<Failure, ({bool success, String message})>> logout({required String empCd}) async {
    try {
      final result = await _dataSource.logout(empCd: empCd);
      // Only drop the session once the backend actually confirms the
      // logout — a "False" status means the user stays signed in on this
      // same screen, so the local session must stay intact too.
      if (result.success) {
        await _secureStorage.clear();
        await _localStorage.clear();
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ({bool success, String message})>> changePassword({
    required String empCd,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final result = await _dataSource.changePassword(
        empCd: empCd,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Right(result);
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
