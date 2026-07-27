import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/employee_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({required this.employeeNumber, required this.pin});

  final String employeeNumber;
  final String pin;
}

/// Authenticates an employee by employee number + PIN.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, ({String message, EmployeeEntity employee})>> call(LoginParams params) {
    return _repository.login(employeeNumber: params.employeeNumber, pin: params.pin);
  }
}
