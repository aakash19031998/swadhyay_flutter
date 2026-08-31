import '../../domain/entities/qc_checker_department_list_entity.dart';

abstract class QcCheckerDepartmentDataSource {
  Future<QcCheckerDepartmentListEntity> getDepartments({required String empCd});
}
