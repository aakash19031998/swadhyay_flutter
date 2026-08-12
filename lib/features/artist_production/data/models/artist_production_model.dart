import '../../domain/entities/artist_production_entity.dart';

class ArtistProductionDetailModel extends ArtistProductionDetailEntity {
  const ArtistProductionDetailModel({
    required super.workType,
    required super.work,
    required super.actualQty,
    required super.totalPoints,
  });

  factory ArtistProductionDetailModel.fromJson(Map<String, dynamic> json) {
    return ArtistProductionDetailModel(
      workType: json['WorkType'] as String? ?? '',
      work: json['Prediction'] as String? ?? '',
      actualQty: ((json['ActualPcsStone'] as num?) ?? 0).round(),
      totalPoints: ((json['TotalPoints'] as num?) ?? 0).toDouble(),
    );
  }
}

class ArtistProductionSummaryModel extends ArtistProductionSummaryEntity {
  const ArtistProductionSummaryModel({
    required super.workType,
    required super.actualQty,
    required super.totalPoints,
  });

  factory ArtistProductionSummaryModel.fromJson(Map<String, dynamic> json) {
    return ArtistProductionSummaryModel(
      workType: json['Process'] as String? ?? '',
      actualQty: ((json['ActualPcsStone'] as num?) ?? 0).round(),
      totalPoints: ((json['TotalPoints'] as num?) ?? 0).toDouble(),
    );
  }
}

class ArtistProductionReportModel extends ArtistProductionReportEntity {
  const ArtistProductionReportModel({
    required super.totalPieces,
    required super.parts,
    required super.points,
    required super.detail,
    required super.summary,
  });

  factory ArtistProductionReportModel.fromJson(Map<String, dynamic> json) {
    return ArtistProductionReportModel(
      totalPieces: ((json['totalPieces'] as num?) ?? 0).round(),
      parts: ((json['parts'] as num?) ?? 0).round(),
      points: ((json['points'] as num?) ?? 0).toDouble(),
      detail: [
        for (final entry in (json['detail'] as List<dynamic>? ?? const []))
          ArtistProductionDetailModel.fromJson(entry as Map<String, dynamic>),
      ],
      summary: [
        for (final entry in (json['summary'] as List<dynamic>? ?? const []))
          ArtistProductionSummaryModel.fromJson(entry as Map<String, dynamic>),
      ],
    );
  }
}
