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

  /// Parses one entry of `BagDetailsNew`'s `data.diamondDetails` array.
  /// [rawWeight] is the exact digit text pulled from the raw response body
  /// (see `RawJsonNumbers`) — used instead of `json['weight']` whenever
  /// available, since decoding that field as a number would drop trailing
  /// zeros the API sent (e.g. "1.4000" becoming "1.4").
  factory DiamondDetailModel.fromApiJson(Map<String, dynamic> json, {String? rawWeight}) {
    return DiamondDetailModel(
      srNo: (json['srNo'] as num).toInt(),
      itemCode: json['itemCode'] as String,
      size: json['size'] as String,
      pcs: (json['pcs'] as num).toInt(),
      weight: rawWeight ?? '${json['weight']}',
      setting: json['setting'] as String,
    );
  }
}
