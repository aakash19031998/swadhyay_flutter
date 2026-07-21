import 'package:equatable/equatable.dart';

/// One day's used/unused minute split, shown as a grouped bar pair on the
/// Timing Report chart.
class TimingReportEntity extends Equatable {
  const TimingReportEntity({
    required this.date,
    required this.usedMinutes,
    required this.unusedMinutes,
  });

  final DateTime date;
  final int usedMinutes;
  final int unusedMinutes;

  @override
  List<Object?> get props => [date, usedMinutes, unusedMinutes];
}
