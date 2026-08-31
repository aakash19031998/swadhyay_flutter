import 'package:equatable/equatable.dart';

/// One selectable option in [QcActionDialog]'s "Diamond QC Checker"
/// dropdown — a `QCRepairList` `DiaQcList` entry.
class DiaQcCheckerEntity extends Equatable {
  const DiaQcCheckerEntity({required this.qcCode, required this.qcName});

  final String qcCode;
  final String qcName;

  @override
  List<Object?> get props => [qcCode, qcName];
}
