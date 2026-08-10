import '../../domain/entities/bag_rm_summary_entity.dart';

class BagRmSummaryModel extends BagRmSummaryEntity {
  const BagRmSummaryModel({
    required super.materialType,
    required super.itemCode,
    required super.size,
    required super.issuedQty,
    required super.wt,
  });

  factory BagRmSummaryModel.fromJson(Map<String, dynamic> json) {
    return BagRmSummaryModel(
      materialType: json['materialType'] as String,
      itemCode: json['itemCode'] as String,
      size: json['size'] as String,
      issuedQty: json['issuedQty'] as String,
      wt: json['wt'] as String,
    );
  }

  /// Parses one entry of `BagDetailsNew`'s `data.rmSummary` array.
  /// [rawCurrentQty]/[rawWt] are the exact digit text pulled from the raw
  /// response body (see `RawJsonNumbers`) — used instead of
  /// `json['CurrentQty']`/`json['Wt']` whenever available, since decoding
  /// those fields as numbers would drop trailing zeros the API sent (e.g.
  /// "1.4000" becoming "1.4").
  factory BagRmSummaryModel.fromApiJson(
    Map<String, dynamic> json, {
    String? rawCurrentQty,
    String? rawWt,
  }) {
    return BagRmSummaryModel(
      materialType: json['MaterialType'] as String? ?? '',
      itemCode: json['ItemCode'] as String? ?? '',
      size: json['Size'] as String? ?? '',
      issuedQty: rawCurrentQty ?? '${json['CurrentQty'] ?? 0}',
      wt: rawWt ?? '${json['Wt'] ?? 0}',
    );
  }
}
