import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordParams {
  const ChangePasswordParams({required this.currentPassword, required this.newPassword});

  final String currentPassword;
  final String newPassword;
}

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call(ChangePasswordParams params) {
    return _repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}
