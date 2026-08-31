import '../../domain/entities/dia_qc_checker_entity.dart';

class DiaQcCheckerModel extends DiaQcCheckerEntity {
  const DiaQcCheckerModel({required super.qcCode, required super.qcName});

  /// One `QCRepairList` `DiaQcList` entry.
  factory DiaQcCheckerModel.fromJson(Map<String, dynamic> json) {
    return DiaQcCheckerModel(
      qcCode: '${json['QcCode']}',
      qcName: json['QcName'] as String? ?? '',
    );
  }
}
