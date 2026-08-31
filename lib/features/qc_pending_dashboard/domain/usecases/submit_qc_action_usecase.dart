import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_repair_qty_entity.dart';
import '../entities/qc_submit_result_entity.dart';
import '../repositories/qc_check_repository.dart';

class SubmitQcActionUseCase {
  const SubmitQcActionUseCase(this._repository);

  final QcCheckRepository _repository;

  Future<Either<Failure, QcSubmitResultEntity>> call({
    required String action,
    required String trnId,
    required String bagNo,
    required String empCd,
    required String userEmpCd,
    required String process,
    required String diaQcCd,
    required List<QcRepairQtyEntity> repairList,
  }) {
    return _repository.submitAction(
      action: action,
      trnId: trnId,
      bagNo: bagNo,
      empCd: empCd,
      userEmpCd: userEmpCd,
      process: process,
      diaQcCd: diaQcCd,
      repairList: repairList,
    );
  }
}
