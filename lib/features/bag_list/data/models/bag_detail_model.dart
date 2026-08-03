import '../../domain/entities/bag_detail_entity.dart';

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
  });

  /// Parses `BagDetailsNew`'s `data.bag_Detail` object.
  factory BagDetailModel.fromApiJson(Map<String, dynamic> json) {
    final String dsCtg = json['DsCtg'] as String? ?? '';
    final String dsSctg = json['DsSctg'] as String? ?? '';
    final int? parts = (json['PARTS'] as num?)?.toInt();

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
    );
  }
}
