import '../models/timing_report_model.dart';

abstract class TimingReportDataSource {
  Future<List<TimingReportModel>> getReport({required int year, required int month});
}
