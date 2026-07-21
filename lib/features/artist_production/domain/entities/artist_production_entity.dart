import 'package:equatable/equatable.dart';

/// One work-type production entry for a given day, within the selected
/// From/To date range on the Artist Production Report screen.
class ArtistProductionEntity extends Equatable {
  const ArtistProductionEntity({
    required this.id,
    required this.workType,
    required this.prediction,
    required this.actualQty,
    required this.totalPoints,
    required this.entryDate,
  });

  final String id;
  final String workType;
  final double prediction;
  final int actualQty;
  final double totalPoints;
  final DateTime entryDate;

  @override
  List<Object?> get props => [id, workType, prediction, actualQty, totalPoints, entryDate];
}
