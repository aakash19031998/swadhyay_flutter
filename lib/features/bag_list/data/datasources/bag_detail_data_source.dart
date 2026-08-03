import '../models/bag_detail_model.dart';

abstract class BagDetailDataSource {
  Future<BagDetailModel> getBagDetail({required String bagNo, required String empCd});
}
