import '../models/qc_repair_checklist_item_model.dart';

/// Always backed by the live `QCRepairList` endpoint (see
/// [QcRepairListRemoteDataSourceImpl]) — like [QcDepartmentDataSource],
/// [QcEmpListDataSource] and [QcBagListDataSource], there is deliberately
/// no mock implementation, so the QC OK/Repair dialog never shows demo data
/// regardless of `AppConfig.useMockData`.
abstract class QcRepairListDataSource {
  Future<List<QcRepairChecklistItemModel>> getRepairList({required String schr, required String empCd});
}
