import '../models/bag_model.dart';

abstract class BagDataSource {
  Future<List<BagModel>> getBags({String query = ''});
}
