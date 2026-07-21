import '../../domain/entities/timing_report_entity.dart';

class TimingReportModel extends TimingReportEntity {
  const TimingReportModel({
    required super.date,
    required super.usedMinutes,
    required super.unusedMinutes,
  });

  factory TimingReportModel.fromJson(Map<String, dynamic> json) {
    return TimingReportModel(
      date: DateTime.parse(json['date'] as String),
      usedMinutes: json['usedMinutes'] as int,
      unusedMinutes: json['unusedMinutes'] as int,
    );
  }
}
