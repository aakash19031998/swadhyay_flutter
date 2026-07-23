import '../../domain/entities/diamond_detail_entity.dart';

class DiamondDetailModel extends DiamondDetailEntity {
  const DiamondDetailModel({
    required super.srNo,
    required super.shape,
    required super.sizeMm,
    required super.pcs,
    required super.weightCt,
    required super.color,
    required super.clarity,
    required super.setting,
  });

  factory DiamondDetailModel.fromJson(Map<String, dynamic> json) {
    return DiamondDetailModel(
      srNo: (json['srNo'] as num).toInt(),
      shape: json['shape'] as String,
      sizeMm: (json['sizeMm'] as num).toDouble(),
      pcs: (json['pcs'] as num).toInt(),
      weightCt: (json['weightCt'] as num).toDouble(),
      color: json['color'] as String,
      clarity: json['clarity'] as String,
      setting: json['setting'] as String,
    );
  }
}
