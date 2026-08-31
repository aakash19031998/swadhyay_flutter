import '../models/qc_assigned_bag_model.dart';

/// Always backed by the live `QcPendingBagList` endpoint (see
/// [QcBagListRemoteDataSourceImpl]) — like [QcDepartmentDataSource] and
/// [QcEmpListDataSource], there is deliberately no mock implementation, so
/// the QC Bag List screen never shows demo data regardless of
/// `AppConfig.useMockData`.
abstract class QcBagListDataSource {
  Future<List<QcAssignedBagModel>> getBagList({required String empCd});
}
