import '../models/bag_completion_master_model.dart';

abstract class BagCompletionMasterDataSource {
  Future<BagCompletionMasterModel> getBagCompletionMaster({required String trnId, required String empCd});
}
