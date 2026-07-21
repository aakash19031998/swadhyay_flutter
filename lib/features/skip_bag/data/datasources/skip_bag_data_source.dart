import '../models/skipped_bag_model.dart';

abstract class SkipBagDataSource {
  Future<List<SkippedBagModel>> getSkippedBags({String query = ''});

  Future<SkippedBagModel> skipBag({required String bagNo, required String reason});
}
