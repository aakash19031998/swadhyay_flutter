import 'package:equatable/equatable.dart';

/// One row of the "QC Prediction Score Matrix" table.
class QcPredictionScoreEntity extends Equatable {
  const QcPredictionScoreEntity({
    required this.process,
    required this.prediction,
    required this.totalPoints,
    required this.repairCaught,
  });

  final String process;
  final String prediction;
  final double totalPoints;
  final int repairCaught;

  @override
  List<Object?> get props => [process, prediction, totalPoints, repairCaught];
}

/// One row of the "Shift & Process Distribution" table.
class QcShiftDistributionEntity extends Equatable {
  const QcShiftDistributionEntity({
    required this.process,
    required this.emrBag,
    required this.points,
    required this.repair,
    required this.dayShiftBags,
    required this.eveningShiftBags,
  });

  final String process;
  final int emrBag;
  final double points;
  final int repair;

  /// Bag count in the 7 AM – 8 PM ("Day") shift window.
  final int dayShiftBags;

  /// Bag count in the 8 PM – 12 AM ("Evening") shift window.
  final int eveningShiftBags;

  @override
  List<Object?> get props => [
    process,
    emrBag,
    points,
    repair,
    dayShiftBags,
    eveningShiftBags,
  ];
}

/// The full QC Checker Report payload for a date range: both tables plus
/// the till-date totals shown in their footers (the Prediction Score
/// Matrix's total points, and the Day/Evening shift split) and in the
/// summary KPI strip above them.
class QcCheckerReportEntity extends Equatable {
  const QcCheckerReportEntity({
    required this.totalPoints,
    required this.totalBagPieces,
    required this.totalRepairCaught,
    required this.ownRepairPoints,
    required this.ownRepairBags,
    required this.totalDayShiftBags,
    required this.totalEveningShiftBags,
    required this.predictionScoreMatrix,
    required this.shiftProcessDistribution,
  });

  final double totalPoints;

  /// Sum of [QcShiftDistributionEntity.emrBag] across
  /// [shiftProcessDistribution], excluding the `"Own Repair"` adjustment
  /// row — that row is a deduction, not a real bag count, and is
  /// surfaced separately via [ownRepairBags].
  final int totalBagPieces;

  /// Sum of [QcPredictionScoreEntity.repairCaught] across
  /// [predictionScoreMatrix].
  final int totalRepairCaught;

  /// The `"Own Repair"` row's `TotalPoints` (0 if that row is absent).
  final double ownRepairPoints;

  /// The `"Own Repair"` row's `EmrBagPieces` (0 if that row is absent).
  final int ownRepairBags;

  final int totalDayShiftBags;
  final int totalEveningShiftBags;
  final List<QcPredictionScoreEntity> predictionScoreMatrix;
  final List<QcShiftDistributionEntity> shiftProcessDistribution;

  @override
  List<Object?> get props => [
    totalPoints,
    totalBagPieces,
    totalRepairCaught,
    ownRepairPoints,
    ownRepairBags,
    totalDayShiftBags,
    totalEveningShiftBags,
    predictionScoreMatrix,
    shiftProcessDistribution,
  ];
}
