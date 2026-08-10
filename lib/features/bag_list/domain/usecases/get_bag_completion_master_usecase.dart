import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bag_completion_master_entity.dart';
import '../repositories/bag_completion_master_repository.dart';

class GetBagCompletionMasterUseCase {
  const GetBagCompletionMasterUseCase(this._repository);

  final BagCompletionMasterRepository _repository;

  Future<Either<Failure, BagCompletionMasterEntity>> call({required String trnId, required String empCd}) {
    return _repository.getBagCompletionMaster(trnId: trnId, empCd: empCd);
  }
}
