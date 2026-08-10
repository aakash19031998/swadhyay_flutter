import '../../domain/entities/design_lab_detail_entity.dart';

class DesignLabDetailModel extends DesignLabDetailEntity {
  const DesignLabDetailModel({
    required super.labourCd,
    required super.labourNm,
    required super.pcs,
  });

  factory DesignLabDetailModel.fromJson(Map<String, dynamic> json) {
    return DesignLabDetailModel(
      labourCd: json['labourCd'] as String? ?? '',
      labourNm: json['labourNm'] as String? ?? '',
      pcs: '${json['pcs'] ?? ''}',
    );
  }
}
