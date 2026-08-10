import '../../domain/entities/bag_detail_entity.dart';
import '../../domain/entities/bag_rm_summary_entity.dart';
import '../../domain/entities/diamond_detail_entity.dart';
import 'bag_rm_summary_model.dart';
import 'diamond_detail_model.dart';

class BagDetailModel extends BagDetailEntity {
  const BagDetailModel({
    super.delDate,
    super.bagQty,
    super.styleNo,
    super.orderNo,
    super.customer,
    super.part,
    super.size,
    super.designCategory,
    super.metal,
    super.designGrossWt,
    super.designNetWt,
    super.designInstr,
    super.custInstr,
    super.stampInstr,
    super.rhodInstr,
    super.diamInstr,
    super.sizeInstr,
    super.byy,
    super.bchr,
    super.bno,
    super.bagCmpCd,
    super.diamondDetails,
    super.rmSummary,
  });

  /// Parses `BagDetailsNew`'s `data.bag_Detail` object; [diamondDetailsJson]
  /// and [rmSummaryJson] are `data.diamondDetails`/`data.rmSummary` — sibling
  /// arrays in the same response, not nested inside [json]. [rawWeights],
  /// [rawCurrentQty] and [rawWt] are each array's numeric fields exactly as
  /// they appear in the raw response text (see `RawJsonNumbers`), zipped in
  /// positionally so those columns never lose the API's original digits.
  factory BagDetailModel.fromApiJson(
    Map<String, dynamic> json, {
    List<dynamic> diamondDetailsJson = const [],
    List<dynamic> rmSummaryJson = const [],
    List<String> rawWeights = const [],
    List<String> rawCurrentQty = const [],
    List<String> rawWt = const [],
  }) {
    final String dsCtg = json['DsCtg'] as String? ?? '';
    final String dsSctg = json['DsSctg'] as String? ?? '';
    final int? parts = (json['PARTS'] as num?)?.toInt();
    final List<DiamondDetailEntity> diamondDetails = [
      for (int i = 0; i < diamondDetailsJson.length; i++)
        DiamondDetailModel.fromApiJson(
          diamondDetailsJson[i] as Map<String, dynamic>,
          rawWeight: i < rawWeights.length ? rawWeights[i] : null,
        ),
    ];
    final List<BagRmSummaryEntity> rmSummary = [
      for (int i = 0; i < rmSummaryJson.length; i++)
        BagRmSummaryModel.fromApiJson(
          rmSummaryJson[i] as Map<String, dynamic>,
          rawCurrentQty: i < rawCurrentQty.length ? rawCurrentQty[i] : null,
          rawWt: i < rawWt.length ? rawWt[i] : null,
        ),
    ];

    return BagDetailModel(
      delDate: DateTime.tryParse(json['ExpDelDate'] as String? ?? ''),
      bagQty: (json['BagQty'] as num?)?.toInt(),
      styleNo: json['StyleCode'] as String?,
      orderNo: json['OrderNo'] as String?,
      customer: json['CUST_CODE'] as String?,
      part: parts == null ? null : '$parts',
      size: json['Prod_SIZE'] as String?,
      designCategory: dsCtg.isEmpty && dsSctg.isEmpty ? null : '$dsCtg/$dsSctg',
      metal: json['Metal'] as String?,
      designGrossWt: (json['GrossWt'] as num?)?.toDouble(),
      designNetWt: (json['NetWeight'] as num?)?.toDouble(),
      designInstr: json['DesignProductionInstruction'] as String?,
      custInstr: json['CustomerProductionInstruction'] as String?,
      stampInstr: json['StampInstruction'] as String?,
      rhodInstr: json['RhodiumInstruction'] as String?,
      diamInstr: json['DiamondInstruction'] as String?,
      sizeInstr: json['SizeInstruction'] as String?,
      byy: json['Byy'] as String?,
      bchr: json['Bchr'] as String?,
      bno: (json['Bno'] as num?)?.toInt(),
      bagCmpCd: json['bag_cmp_cd'] as String?,
      diamondDetails: diamondDetails,
      rmSummary: rmSummary,
    );
  }
}
