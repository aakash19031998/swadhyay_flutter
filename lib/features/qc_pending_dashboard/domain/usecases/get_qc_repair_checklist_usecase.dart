import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_repair_checklist_item_entity.dart';
import '../repositories/qc_check_repository.dart';

class GetQcRepairChecklistUseCase {
  const GetQcRepairChecklistUseCase(this._repository);

  final QcCheckRepository _repository;

  Future<Either<Failure, List<QcRepairChecklistItemEntity>>> call({required String schr, required String empCd}) {
    return _repository.getRepairChecklist(schr: schr, empCd: empCd);
  }
}
