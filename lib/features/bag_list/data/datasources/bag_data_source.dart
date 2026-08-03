import '../models/bag_model.dart';

abstract class BagDataSource {
  /// Always the full, unfiltered list for [empCd] — search is applied
  /// client-side in `BagListController`, not here (no source of this data
  /// supports server-side search). `bagCount`/`pcsCount` are the server's
  /// own totals for that same full list.
  Future<({int bagCount, int pcsCount, List<BagModel> bags})> getBags({required String empCd});
}
