import '../../domain/entities/qc_emp_list_entity.dart';

/// Always backed by the live `DeptQCPendingEmpList` endpoint (see
/// [QcEmpListRemoteDataSourceImpl]) — like [QcDepartmentDataSource], there
/// is deliberately no mock implementation, so the QC Checker screen's
/// employee grid never shows demo data regardless of
/// `AppConfig.useMockData`.
abstract class QcEmpListDataSource {
  Future<QcEmpListEntity> getEmpList({required String deptCd});
}
