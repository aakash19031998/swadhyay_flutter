import '../../domain/entities/qc_repair_checklist_item_entity.dart';

class QcRepairChecklistItemModel extends QcRepairChecklistItemEntity {
  const QcRepairChecklistItemModel({required super.id, required super.label});

  /// One `QCRepairList` `RepairList` entry.
  factory QcRepairChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return QcRepairChecklistItemModel(
      id: '${json['RepairId']}',
      label: json['Repair'] as String? ?? '',
    );
  }
}
