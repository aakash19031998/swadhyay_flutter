import '../../domain/entities/comp_pred_entity.dart';

class CompPredModel extends CompPredEntity {
  const CompPredModel({required super.prediction, required super.stone});

  /// Parses one `BagDoneDetail` `data.CompPred` array item.
  factory CompPredModel.fromApiJson(Map<String, dynamic> json) {
    return CompPredModel(
      prediction: json['Prediction'] as String? ?? '',
      stone: (json['Stone'] as num?)?.toDouble() ?? 0,
    );
  }
}
