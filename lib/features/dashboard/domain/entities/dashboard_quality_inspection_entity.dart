import 'package:equatable/equatable.dart';

/// One row of the "Quality Inspection" card's QC-queue breakdown (e.g.
/// "Stone Setting QC — 24 pcs").
class DashboardQcQueueItemEntity extends Equatable {
  const DashboardQcQueueItemEntity({required this.label, required this.pieces});

  final String label;
  final int pieces;

  @override
  List<Object?> get props => [label, pieces];
}

class DashboardQualityInspectionEntity extends Equatable {
  const DashboardQualityInspectionEntity({
    required this.piecesWaiting,
    required this.urgentCount,
    required this.queue,
  });

  final int piecesWaiting;

  /// Waiting more than 24h.
  final int urgentCount;
  final List<DashboardQcQueueItemEntity> queue;

  @override
  List<Object?> get props => [piecesWaiting, urgentCount, queue];
}
