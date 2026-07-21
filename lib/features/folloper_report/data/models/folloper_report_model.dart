import '../../domain/entities/folloper_report_entity.dart';

class FolloperReportModel extends FolloperReportEntity {
  const FolloperReportModel({
    required super.id,
    required super.folloperName,
    required super.artistName,
    required super.task,
    required super.hoursWorked,
    required super.workDate,
  });

  factory FolloperReportModel.fromJson(Map<String, dynamic> json) {
    return FolloperReportModel(
      id: json['id'] as String,
      folloperName: json['folloperName'] as String,
      artistName: json['artistName'] as String,
      task: json['task'] as String,
      hoursWorked: (json['hoursWorked'] as num).toDouble(),
      workDate: DateTime.parse(json['workDate'] as String),
    );
  }
}
