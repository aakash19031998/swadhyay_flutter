import '../../domain/entities/design_bom_item_entity.dart';

class DesignBomItemModel extends DesignBomItemEntity {
  const DesignBomItemModel({
    required super.srNo,
    required super.rmType,
    required super.rmCode,
    required super.sizeName,
    required super.pcs,
    required super.rmWeight,
    required super.setCode,
    required super.stonePosition,
  });

  factory DesignBomItemModel.fromJson(Map<String, dynamic> json) {
    return DesignBomItemModel(
      srNo: (json['srNo'] as num).toInt(),
      rmType: json['rmType'] as String? ?? '',
      rmCode: json['rmCode'] as String? ?? '',
      sizeName: json['sizeName'] as String? ?? '',
      pcs: '${json['pcs'] ?? ''}',
      rmWeight: '${json['rmWeight'] ?? ''}',
      setCode: json['setCode'] as String? ?? '',
      stonePosition: json['stonePosition'] as String? ?? '',
    );
  }
}
