import '../models/design_master_model.dart';

abstract class DesignMasterDataSource {
  /// Returns `null` when no design matches [styleNo].
  Future<DesignMasterModel?> getDesignMaster({required String styleNo});
}
