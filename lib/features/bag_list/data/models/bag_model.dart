import '../../domain/entities/bag_entity.dart';
import 'bag_media_model.dart';

class BagModel extends BagEntity {
  const BagModel({
    required super.id,
    required super.bagNo,
    required super.designNo,
    required super.locationCode,
    required super.filling,
    required super.bagQty,
    required super.designPoints,
    required super.assignedDate,
    super.imageUrl,
    super.media,
  });

  factory BagModel.fromJson(Map<String, dynamic> json) {
    return BagModel(
      id: json['id'] as String,
      bagNo: json['bagNo'] as String,
      designNo: json['designNo'] as String,
      imageUrl: json['imageUrl'] as String?,
      locationCode: json['locationCode'] as String? ?? '',
      filling: json['filling'] as String? ?? '',
      bagQty: (json['bagQty'] as num?)?.toInt() ?? 1,
      designPoints: (json['designPoints'] as num?)?.toDouble() ?? 0,
      assignedDate: DateTime.parse(json['assignedDate'] as String),
      media: (json['media'] as List<dynamic>? ?? [])
          .map((m) => BagMediaModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
