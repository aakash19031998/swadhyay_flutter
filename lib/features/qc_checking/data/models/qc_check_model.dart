import '../../domain/entities/qc_check_entity.dart';

class QcCheckModel extends QcCheckEntity {
  const QcCheckModel({
    required super.id,
    required super.bagNo,
    required super.designNo,
    required super.checkedBy,
    required super.checkedAt,
    required super.result,
    super.remarks,
  });

  factory QcCheckModel.fromJson(Map<String, dynamic> json) {
    return QcCheckModel(
      id: json['id'] as String,
      bagNo: json['bagNo'] as String,
      designNo: json['designNo'] as String,
      checkedBy: json['checkedBy'] as String,
      checkedAt: DateTime.parse(json['checkedAt'] as String),
      result: QcResult.values.byName(json['result'] as String),
      remarks: json['remarks'] as String?,
    );
  }
}
