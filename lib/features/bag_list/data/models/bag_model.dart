import '../../domain/entities/bag_entity.dart';
import 'bag_media_model.dart';
import 'bag_rm_summary_model.dart';
import 'diamond_detail_model.dart';

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
    super.diamondDetails,
    super.rmSummary,
  });

  factory BagModel.fromJson(Map<String, dynamic> json) {
    return BagModel(
      id: json['id'] as String,
      bagNo: json['bagNo'] as String,
      designNo: json['designNo'] as String,
      imageUrl: json['imageUrl'] as String?,
      locationCode: json['locationCode'] as String? ?? '',
      department: json['department'] as String? ?? '',
      filling: json['filling'] as String? ?? '',
      bagQty: (json['bagQty'] as num?)?.toInt() ?? 1,
      designPoints: (json['designPoints'] as num?)?.toDouble() ?? 0,
      assignedDate: DateTime.parse(json['assignedDate'] as String),
      media: (json['media'] as List<dynamic>? ?? [])
          .map((m) => BagMediaModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      metal: json['metal'] as String?,
      designGrossWt: (json['designGrossWt'] as num?)?.toDouble(),
      designNetWt: (json['designNetWt'] as num?)?.toDouble(),
      designInstr: json['designInstr'] as String?,
      custInstr: json['custInstr'] as String?,
      stampInstr: json['stampInstr'] as String?,
      rhodInstr: json['rhodInstr'] as String?,
      diamInstr: json['diamInstr'] as String?,
      sizeInstr: json['sizeInstr'] as String?,
      delDate: json['delDate'] == null ? null : DateTime.parse(json['delDate'] as String),
      size: json['size'] as String?,
      customer: json['customer'] as String?,
      poNo: json['poNo'] as String?,
      part: json['part'] as String?,
      pieceQty: (json['pieceQty'] as num?)?.toInt(),
      styleNo: json['styleNo'] as String?,
      diamondDetails: (json['diamondDetails'] as List<dynamic>? ?? [])
          .map((d) => DiamondDetailModel.fromJson(d as Map<String, dynamic>))
          .toList(),
      rmSummary: (json['rmSummary'] as List<dynamic>? ?? [])
          .map((r) => BagRmSummaryModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
