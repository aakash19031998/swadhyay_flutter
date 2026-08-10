import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/pause_reason_entity.dart';
import '../repositories/pause_reason_repository.dart';

class GetPauseReasonsUseCase {
  const GetPauseReasonsUseCase(this._repository);

  final PauseReasonRepository _repository;

  Future<Either<Failure, List<PauseReasonEntity>>> call() => _repository.getReasons();
}
