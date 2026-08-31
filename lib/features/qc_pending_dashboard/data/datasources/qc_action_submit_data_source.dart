import '../../domain/entities/qc_repair_qty_entity.dart';
import '../../domain/entities/qc_submit_result_entity.dart';

/// Always backed by the live `BagFinalReceive` endpoint (see
/// [QcActionSubmitRemoteDataSourceImpl]) — like every other data source in
/// this feature, there is deliberately no mock implementation.
abstract class QcActionSubmitDataSource {
  Future<QcSubmitResultEntity> submit({
    required String action,
    required String trnId,
    required String bagNo,
    required String empCd,
    required String userEmpCd,
    required String process,
    required String diaQcCd,
    required List<QcRepairQtyEntity> repairList,
  });
}
