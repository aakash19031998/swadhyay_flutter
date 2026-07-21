import '../../../../core/config/app_config.dart';
import '../models/timing_report_model.dart';
import 'timing_report_data_source.dart';

class TimingReportMockDataSourceImpl implements TimingReportDataSource {
  @override
  Future<List<TimingReportModel>> getReport({required int year, required int month}) async {
    await Future.delayed(AppConfig.mockLatency);

    final int daysInMonth = DateTime(year, month + 1, 0).day;

    return List.generate(daysInMonth, (index) {
      final int day = index + 1;
      final int used = 300 + ((day * 47) % 650);
      final int unused = day % 7 == 0 ? 100 + ((day * 13) % 250) : 0;
      return TimingReportModel(
        date: DateTime(year, month, day),
        usedMinutes: used,
        unusedMinutes: unused,
      );
    });
  }
}
