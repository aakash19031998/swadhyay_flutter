import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/pause_reason_entity.dart';

abstract class PauseReasonRepository {
  Future<Either<Failure, List<PauseReasonEntity>>> getReasons();
}
