import '../../../../core/config/app_config.dart';
import '../../domain/entities/qc_check_entity.dart';
import '../models/qc_check_model.dart';
import 'qc_check_data_source.dart';

class QcCheckMockDataSourceImpl implements QcCheckDataSource {
  static final List<QcCheckModel> _checks = List.generate(15, (index) {
    final results = QcResult.values;
    return QcCheckModel(
      id: 'qc_$index',
      bagNo: 'BAG${(1000 + index).toString()}',
      designNo: 'DSN${(500 + index).toString()}',
      checkedBy: 'Inspector ${(index % 4) + 1}',
      checkedAt: DateTime.now().subtract(Duration(hours: index * 3)),
      result: results[index % results.length],
      remarks: index % 3 == 0 ? 'Minor polish required' : null,
    );
  });

  @override
  Future<List<QcCheckModel>> getChecks({String query = ''}) async {
    await Future.delayed(AppConfig.mockLatency);

    if (query.isEmpty) return _checks;
    final String needle = query.toLowerCase();
    return _checks
        .where((c) => c.bagNo.toLowerCase().contains(needle) || c.designNo.toLowerCase().contains(needle))
        .toList();
  }
}
