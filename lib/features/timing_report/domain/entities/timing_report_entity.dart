import 'package:equatable/equatable.dart';

/// One day's used/unused minute split, shown as a grouped bar pair on the
/// Timing Report chart. [punchedMinutes] (used + unused, but sent as its
/// own field rather than always exactly matching the sum) feeds the Till
/// Date Summary's "Total Minutes" chip.
class TimingReportEntity extends Equatable {
  const TimingReportEntity({
    required this.date,
    required this.usedMinutes,
    required this.unusedMinutes,
    required this.punchedMinutes,
  });

  final DateTime date;
  final double usedMinutes;
  final double unusedMinutes;
  final double punchedMinutes;

  @override
  List<Object?> get props => [date, usedMinutes, unusedMinutes, punchedMinutes];
}
