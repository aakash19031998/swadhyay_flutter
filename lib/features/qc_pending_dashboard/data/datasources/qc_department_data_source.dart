import '../../domain/entities/qc_department_list_entity.dart';

/// Always backed by the live `QCDeptList` endpoint (see
/// [QcDepartmentRemoteDataSourceImpl]) — like every other data source in
/// this feature, there is deliberately no mock implementation of this, so
/// the "SELECT DEPARTMENT" sidebar never shows demo data regardless of
/// `AppConfig.useMockData`.
abstract class QcDepartmentDataSource {
  Future<QcDepartmentListEntity> getDepartments({required String empCd});
}
