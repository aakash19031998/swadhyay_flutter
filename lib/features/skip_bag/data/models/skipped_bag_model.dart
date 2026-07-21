import '../../domain/entities/skipped_bag_entity.dart';

class SkippedBagModel extends SkippedBagEntity {
  const SkippedBagModel({
    required super.id,
    required super.bagNo,
    required super.reason,
    required super.skippedAt,
  });

  factory SkippedBagModel.fromJson(Map<String, dynamic> json) {
    return SkippedBagModel(
      id: json['id'] as String,
      bagNo: json['bagNo'] as String,
      reason: json['reason'] as String,
      skippedAt: DateTime.parse(json['skippedAt'] as String),
    );
  }
}
