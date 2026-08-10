import '../../domain/entities/pause_reason_entity.dart';

class PauseReasonModel extends PauseReasonEntity {
  const PauseReasonModel({required super.reasonId, required super.reasonDesc});

  factory PauseReasonModel.fromJson(Map<String, dynamic> json) {
    return PauseReasonModel(
      reasonId: (json['reasonId'] as num?)?.toInt() ?? 0,
      reasonDesc: json['reasonDesc'] as String? ?? '',
    );
  }
}
