import 'package:equatable/equatable.dart';

import 'department_entity.dart';

/// `QCDeptList`'s full response payload — the department list itself plus
/// the `auto_update` flag ("Y"/"N") that gates whether the QC Checker grid
/// should silently auto-refresh `DeptQCPendingEmpList` every 60s (see
/// `QcPendingDashboardController`).
class QcDepartmentListEntity extends Equatable {
  const QcDepartmentListEntity({required this.departments, required this.autoUpdate});

  final List<DepartmentEntity> departments;
  final bool autoUpdate;

  @override
  List<Object?> get props => [departments, autoUpdate];
}
