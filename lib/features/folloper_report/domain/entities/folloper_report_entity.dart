import 'package:equatable/equatable.dart';

/// "Folloper" is this factory's term for an artist's assistant/helper.
class FolloperReportEntity extends Equatable {
  const FolloperReportEntity({
    required this.id,
    required this.folloperName,
    required this.artistName,
    required this.task,
    required this.hoursWorked,
    required this.workDate,
  });

  final String id;
  final String folloperName;
  final String artistName;
  final String task;
  final double hoursWorked;
  final DateTime workDate;

  @override
  List<Object?> get props => [id, folloperName, artistName, task, hoursWorked, workDate];
}
