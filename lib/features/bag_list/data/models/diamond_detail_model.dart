import '../../domain/entities/diamond_detail_entity.dart';

class DiamondDetailModel extends DiamondDetailEntity {
  const DiamondDetailModel({
    required super.srNo,
    required super.itemCode,
    required super.size,
    required super.pcs,
    required super.weight,
    required super.setting,
  });

  factory DiamondDetailModel.fromJson(Map<String, dynamic> json) {
    return DiamondDetailModel(
      srNo: (json['srNo'] as num).toInt(),
      itemCode: json['itemCode'] as String,
      size: (json['size'] as num).toDouble(),
      pcs: (json['pcs'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      setting: json['setting'] as String,
    );
  }
}
