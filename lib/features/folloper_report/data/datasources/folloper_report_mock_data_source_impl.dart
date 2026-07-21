import '../../../../core/config/app_config.dart';
import '../models/folloper_report_model.dart';
import 'folloper_report_data_source.dart';

class FolloperReportMockDataSourceImpl implements FolloperReportDataSource {
  static const List<String> _tasks = ['Cleaning', 'Buffing', 'Assisting Setting', 'Material Prep'];

  static final List<FolloperReportModel> _entries = List.generate(14, (index) {
    return FolloperReportModel(
      id: 'folloper_$index',
      folloperName: 'Folloper ${(index % 5) + 1}',
      artistName: 'Artist ${(index % 6) + 1}',
      task: _tasks[index % _tasks.length],
      hoursWorked: 4 + (index % 5) * 0.5,
      workDate: DateTime.now().subtract(Duration(days: index)),
    );
  });

  @override
  Future<List<FolloperReportModel>> getReport({String query = ''}) async {
    await Future.delayed(AppConfig.mockLatency);

    if (query.isEmpty) return _entries;
    final String needle = query.toLowerCase();
    return _entries
        .where((e) =>
            e.folloperName.toLowerCase().contains(needle) || e.artistName.toLowerCase().contains(needle))
        .toList();
  }
}
