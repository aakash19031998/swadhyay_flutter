import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, ({bool success, String message})>> call({required String empCd}) {
    return _repository.logout(empCd: empCd);
  }
}
