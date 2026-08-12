import '../models/timing_report_model.dart';

abstract class TimingReportDataSource {
  Future<List<TimingReportModel>> getReport({required String empCd});
}
