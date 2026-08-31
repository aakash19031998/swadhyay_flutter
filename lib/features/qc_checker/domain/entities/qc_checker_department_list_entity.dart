import 'package:equatable/equatable.dart';

import '../../../qc_pending_dashboard/domain/entities/department_entity.dart';
import '../../../qc_pending_dashboard/domain/entities/dia_qc_checker_entity.dart';

/// `QCDepartmentN`'s `data` — `QcDeptList` (the department sidebar) and
/// `DiaQcList` (the "Diamond QC Checker" dropdown), fetched together in one
/// call rather than two.
class QcCheckerDepartmentListEntity extends Equatable {
  const QcCheckerDepartmentListEntity({
    required this.departments,
    required this.diaQcCheckers,
  });

  final List<DepartmentEntity> departments;
  final List<DiaQcCheckerEntity> diaQcCheckers;

  @override
  List<Object?> get props => [departments, diaQcCheckers];
}
