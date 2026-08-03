import '../../domain/entities/bag_rm_summary_entity.dart';

class BagRmSummaryModel extends BagRmSummaryEntity {
  const BagRmSummaryModel({
    required super.materialType,
    required super.itemCode,
    required super.size,
    required super.issuedQty,
  });

  factory BagRmSummaryModel.fromJson(Map<String, dynamic> json) {
    return BagRmSummaryModel(
      materialType: json['materialType'] as String,
      itemCode: json['itemCode'] as String,
      size: json['size'] as String,
      issuedQty: json['issuedQty'] as String,
    );
  }
}
