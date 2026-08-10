import '../../domain/entities/pending_setting_entity.dart';

class PendingSettingModel extends PendingSettingEntity {
  const PendingSettingModel({
    required super.trnId,
    required super.setId,
    required super.pred,
    required super.pcs,
  });

  /// Parses one `BagDoneDetail` `data.PndPred` array item. `TrnId` is read
  /// via `toString()` since the backend isn't guaranteed to send it as a
  /// JSON string vs. number consistently.
  factory PendingSettingModel.fromApiJson(Map<String, dynamic> json) {
    return PendingSettingModel(
      trnId: json['TrnId']?.toString() ?? '',
      setId: (json['SetID'] as num?)?.toInt() ?? 0,
      pred: json['Pred'] as String? ?? '',
      pcs: (json['Pcs'] as num?)?.toInt() ?? 0,
    );
  }
}
