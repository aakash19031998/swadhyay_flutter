import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_assigned_bag_entity.dart';
import '../repositories/qc_check_repository.dart';

class GetQcAssignedBagsUseCase {
  const GetQcAssignedBagsUseCase(this._repository);

  final QcCheckRepository _repository;

  Future<Either<Failure, List<QcAssignedBagEntity>>> call({required String empCode}) {
    return _repository.getAssignedBags(empCode: empCode);
  }
}
