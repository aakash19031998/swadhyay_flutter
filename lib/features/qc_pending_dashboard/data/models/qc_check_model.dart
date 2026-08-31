import '../../domain/entities/qc_check_entity.dart';

class QcCheckModel extends QcCheckEntity {
  const QcCheckModel({
    required super.empCode,
    required super.empName,
    required super.totalBags,
    required super.totalPieces,
    super.imageUrl,
  });

  /// One `DeptQCPendingEmpList` entry.
  factory QcCheckModel.fromJson(Map<String, dynamic> json) {
    return QcCheckModel(
      empCode: '${json['EmpCd']}',
      empName: json['EmpName'] as String? ?? '',
      totalBags: (json['Bags'] as num?)?.toInt() ?? 0,
      totalPieces: (json['Pcs'] as num?)?.toInt() ?? 0,
      imageUrl: json['EmpImg'] as String?,
    );
  }
}
