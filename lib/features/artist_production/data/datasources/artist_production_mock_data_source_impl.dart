import '../../../../core/config/app_config.dart';
import '../models/artist_production_model.dart';
import 'artist_production_data_source.dart';

class ArtistProductionMockDataSourceImpl implements ArtistProductionDataSource {
  static const List<String> _workTypes = ['Setting', 'Polish', 'Casting', 'Filing', 'Rhodium'];

  static final List<ArtistProductionModel> _entries = List.generate(40, (index) {
    final String workType = _workTypes[index % _workTypes.length];
    return ArtistProductionModel(
      id: 'production_$index',
      workType: workType,
      prediction: 8 + (index % 5) * 1.5,
      actualQty: 4 + (index % 7),
      totalPoints: 6 + (index % 6) * 2.25,
      entryDate: DateTime.now().subtract(Duration(days: index % 20)),
    );
  });

  @override
  Future<List<ArtistProductionModel>> getProduction({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    await Future.delayed(AppConfig.mockLatency);

    final DateTime start = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final DateTime end = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);

    return _entries.where((entry) => !entry.entryDate.isBefore(start) && !entry.entryDate.isAfter(end)).toList();
  }
}
