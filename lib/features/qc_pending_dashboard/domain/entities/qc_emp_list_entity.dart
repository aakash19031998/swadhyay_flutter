import 'package:equatable/equatable.dart';

import 'dia_qc_checker_entity.dart';
import 'qc_check_entity.dart';

/// `DeptQCPendingEmpList`'s full response payload — the employee grid
/// (`EmpList`) and the "Diamond QC Checker" master list (`DiaQcList`) for
/// the currently selected department, fetched together.
class QcEmpListEntity extends Equatable {
  const QcEmpListEntity({required this.checks, required this.diaQcList});

  final List<QcCheckEntity> checks;
  final List<DiaQcCheckerEntity> diaQcList;

  @override
  List<Object?> get props => [checks, diaQcList];
}
