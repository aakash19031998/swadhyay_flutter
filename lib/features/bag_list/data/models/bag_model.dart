import '../../domain/entities/bag_entity.dart';

class BagModel extends BagEntity {
  const BagModel({
    required super.id,
    required super.bagNo,
    required super.designNo,
    required super.locationCode,
    required super.department,
    required super.filling,
    required super.bagQty,
    required super.designPoints,
    required super.assignedDate,
    super.imageUrl,
    super.media,
    super.metal,
    super.designGrossWt,
    super.designNetWt,
    super.designInstr,
    super.custInstr,
    super.stampInstr,
    super.rhodInstr,
    super.diamInstr,
    super.sizeInstr,
    super.delDate,
    super.size,
    super.customer,
    super.poNo,
    super.part,
    super.pieceQty,
    super.styleNo,
    super.designCategory,
    super.diamondDetails,
    super.rmSummary,
  });

  /// Parses one entry of `IssuedBagListNew`'s `data.bag_list`. Numeric-ish
  /// fields (`bag_qty`, `bag_points`) come through as strings in this API,
  /// not numbers. Only the fields this screen actually binds are mapped —
  /// everything else (manufacturing instructions, diamond details, RM
  /// summary, etc.) isn't part of this response and stays at its default,
  /// same as before this endpoint existed.
  factory BagModel.fromApiJson(Map<String, dynamic> json) {
    final String deptCd = json['dept_cd'] as String? ?? '';
    final String bagProcessNm = json['bag_process_nm'] as String? ?? '';
    final String? img3DPath = json['Img3DPath'] as String?;

    return BagModel(
      id: '${json['trn_id']}',
      bagNo: json['bag_no'] as String? ?? '',
      designNo: json['design_cd'] as String? ?? '',
      imageUrl: (img3DPath == null || img3DPath.isEmpty) ? null : img3DPath,
      locationCode: json['order_no'] as String? ?? '',
      designCategory: json['design_ctg'] as String?,
      department: bagProcessNm.isNotEmpty ? '$deptCd | $bagProcessNm' : '$deptCd ',
      filling: json['process'] as String? ?? '',
      bagQty: int.tryParse(json['bag_qty'] as String? ?? '') ?? 1,
      designPoints: double.tryParse(json['bag_points'] as String? ?? '') ?? 0,
      // Not part of this API's response; not displayed by the bag list or
      // detail screens.
      assignedDate: DateTime.now(),
    );
  }
}
