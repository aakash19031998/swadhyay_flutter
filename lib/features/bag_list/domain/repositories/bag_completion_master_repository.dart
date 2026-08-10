import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bag_completion_master_entity.dart';

abstract class BagCompletionMasterRepository {
  Future<Either<Failure, BagCompletionMasterEntity>> getBagCompletionMaster({
    required String trnId,
    required String empCd,
  });
}
