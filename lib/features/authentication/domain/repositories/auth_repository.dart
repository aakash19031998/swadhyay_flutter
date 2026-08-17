import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/employee_entity.dart';

/// Authentication contract the presentation layer programs against. Data
/// layer provides the only implementation, backed by either a real or mock
/// data source depending on [AppConfig.useMockData].
abstract class AuthRepository {
  Future<Either<Failure, ({String message, EmployeeEntity employee})>> login({
    required String employeeNumber,
    required String pin,
  });

  Future<Either<Failure, ({bool success, String message})>> logout({required String empCd});

  Future<Either<Failure, ({bool success, String message})>> changePassword({
    required String empCd,
    required String currentPassword,
    required String newPassword,
  });

  Future<EmployeeEntity?> currentEmployee();
}
