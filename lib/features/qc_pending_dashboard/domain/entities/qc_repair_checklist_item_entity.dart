import 'package:equatable/equatable.dart';

/// One row of the QC Repair checklist shown in [QcActionDialog] — a
/// `QCRepairList` `RepairList` entry, always fetched live (see
/// `QcRepairListDataSource`) for the tapped bag's `Process`.
class QcRepairChecklistItemEntity extends Equatable {
  const QcRepairChecklistItemEntity({required this.id, required this.label});

  final String id;
  final String label;

  @override
  List<Object?> get props => [id, label];
}
