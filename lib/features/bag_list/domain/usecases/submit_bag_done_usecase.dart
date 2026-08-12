import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/bag_done_submit_repository.dart';

class SubmitBagDoneUseCase {
  const SubmitBagDoneUseCase(this._repository);

  final BagDoneSubmitRepository _repository;

  Future<Either<Failure, ({bool success, String message})>> call({
    required String trnId,
    required String proId,
    required String empCd,
  }) {
    return _repository.submit(trnId: trnId, proId: proId, empCd: empCd);
  }
}
