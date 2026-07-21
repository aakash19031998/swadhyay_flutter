import '../../domain/entities/artist_production_entity.dart';

class ArtistProductionModel extends ArtistProductionEntity {
  const ArtistProductionModel({
    required super.id,
    required super.workType,
    required super.prediction,
    required super.actualQty,
    required super.totalPoints,
    required super.entryDate,
  });

  factory ArtistProductionModel.fromJson(Map<String, dynamic> json) {
    return ArtistProductionModel(
      id: json['id'] as String,
      workType: json['workType'] as String,
      prediction: (json['prediction'] as num).toDouble(),
      actualQty: json['actualQty'] as int,
      totalPoints: (json['totalPoints'] as num).toDouble(),
      entryDate: DateTime.parse(json['entryDate'] as String),
    );
  }
}
