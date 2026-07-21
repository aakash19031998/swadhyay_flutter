import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/skipped_bag_model.dart';
import 'skip_bag_data_source.dart';

class SkipBagMockDataSourceImpl implements SkipBagDataSource {
  final List<SkippedBagModel> _skippedBags = List.generate(6, (index) {
    return SkippedBagModel(
      id: 'skipped_$index',
      bagNo: 'BAG${(2000 + index).toString()}',
      reason: index.isEven ? 'Damaged' : 'Missing stone',
      skippedAt: DateTime.now().subtract(Duration(days: index)),
    );
  });

  @override
  Future<List<SkippedBagModel>> getSkippedBags({String query = ''}) async {
    await Future.delayed(AppConfig.mockLatency);

    if (query.isEmpty) return _skippedBags;
    final String needle = query.toLowerCase();
    return _skippedBags.where((bag) => bag.bagNo.toLowerCase().contains(needle)).toList();
  }

  @override
  Future<SkippedBagModel> skipBag({required String bagNo, required String reason}) async {
    await Future.delayed(AppConfig.mockLatency);

    if (bagNo.trim().isEmpty) {
      throw const ServerException(message: 'Bag number is required');
    }

    final SkippedBagModel entry = SkippedBagModel(
      id: 'skipped_${DateTime.now().millisecondsSinceEpoch}',
      bagNo: bagNo.trim(),
      reason: reason,
      skippedAt: DateTime.now(),
    );
    _skippedBags.insert(0, entry);
    return entry;
  }
}
