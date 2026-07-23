import '../../domain/entities/bag_rm_summary_entity.dart';

class BagRmSummaryModel extends BagRmSummaryEntity {
  const BagRmSummaryModel({
    required super.materialCode,
    required super.description,
    required super.allocatedQty,
    required super.issuedQty,
    required super.status,
  });

  factory BagRmSummaryModel.fromJson(Map<String, dynamic> json) {
    return BagRmSummaryModel(
      materialCode: json['materialCode'] as String,
      description: json['description'] as String,
      allocatedQty: json['allocatedQty'] as String,
      issuedQty: json['issuedQty'] as String,
      status: json['status'] as String,
    );
  }
}
