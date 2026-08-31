import '../../../qc_pending_dashboard/data/models/qc_assigned_bag_model.dart';

abstract class QcCheckerBagSearchDataSource {
  Future<List<QcAssignedBagModel>> searchBag({required String bagBarcode});
}
