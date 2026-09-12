import 'package:equatable/equatable.dart';

/// "Today's Production" card — [completedPercent] is derived by the view
/// from [completed]/[shiftTarget] rather than stored here, so it can never
/// drift out of sync with the two numbers it's computed from.
class DashboardProductionEntity extends Equatable {
  const DashboardProductionEntity({
    required this.shiftTarget,
    required this.totalBacklog,
    required this.completed,
    required this.paceVsStandard,
  });

  final int shiftTarget;
  final int totalBacklog;
  final int completed;

  /// Pieces ahead of (positive) or behind (negative) the standard run rate
  /// for this point in the shift — shown as "Pace: -6 pcs vs standard run".
  final int paceVsStandard;

  @override
  List<Object?> get props => [
    shiftTarget,
    totalBacklog,
    completed,
    paceVsStandard,
  ];
}
