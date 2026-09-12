import 'package:equatable/equatable.dart';

enum DashboardDayStatus { completed, current, upcoming }

/// One bar on the "Day-to-Day Output" chart. [label] is the day's own
/// text — "Today" for whichever entry is [DashboardDayStatus.current], a
/// weekday abbreviation otherwise. [percent] drives both the bar's height
/// and the percentage label drawn above it.
class DashboardDayEntity extends Equatable {
  const DashboardDayEntity({
    required this.label,
    required this.status,
    required this.percent,
  });

  final String label;
  final DashboardDayStatus status;
  final int percent;

  @override
  List<Object?> get props => [label, status, percent];
}

/// "Target and Achievement" card — [remaining] and the "% Met" badge are
/// derived by the view from [weeklyTarget]/[outputToDate] rather than
/// stored here, so they can never drift out of sync with the two numbers
/// they're computed from.
class DashboardTargetAchievementEntity extends Equatable {
  const DashboardTargetAchievementEntity({
    required this.weeklyTarget,
    required this.outputToDate,
    required this.days,
  });

  final int weeklyTarget;
  final int outputToDate;
  final List<DashboardDayEntity> days;

  @override
  List<Object?> get props => [weeklyTarget, outputToDate, days];
}
