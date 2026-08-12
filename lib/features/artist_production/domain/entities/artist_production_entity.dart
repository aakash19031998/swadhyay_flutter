import 'package:equatable/equatable.dart';

/// One `detail` row from `ArtistProductionRpt` — [work] is a work-item
/// description (e.g. "SQUARE POINTER"), not a numeric prediction.
class ArtistProductionDetailEntity extends Equatable {
  const ArtistProductionDetailEntity({
    required this.workType,
    required this.work,
    required this.actualQty,
    required this.totalPoints,
  });

  final String workType;
  final String work;
  final int actualQty;
  final double totalPoints;

  @override
  List<Object?> get props => [workType, work, actualQty, totalPoints];
}

/// One `summary` row from `ArtistProductionRpt`, keyed by [workType]
/// (`Process` in the API) instead of a per-work-item breakdown — includes
/// the API's own "TOTAL :-"/"REPAIR TOTAL :-" aggregate rows as-is.
class ArtistProductionSummaryEntity extends Equatable {
  const ArtistProductionSummaryEntity({
    required this.workType,
    required this.actualQty,
    required this.totalPoints,
  });

  final String workType;
  final int actualQty;
  final double totalPoints;

  @override
  List<Object?> get props => [workType, actualQty, totalPoints];
}

/// The full `ArtistProductionRpt` `data` object: the three till-date KPI
/// totals plus the `detail` and `summary` rows, all in one response.
class ArtistProductionReportEntity extends Equatable {
  const ArtistProductionReportEntity({
    required this.totalPieces,
    required this.parts,
    required this.points,
    required this.detail,
    required this.summary,
  });

  final int totalPieces;
  final int parts;
  final double points;
  final List<ArtistProductionDetailEntity> detail;
  final List<ArtistProductionSummaryEntity> summary;

  @override
  List<Object?> get props => [totalPieces, parts, points, detail, summary];
}
