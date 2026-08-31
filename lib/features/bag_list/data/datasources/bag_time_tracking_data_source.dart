abstract class BagTimeTrackingDataSource {
  Future<({bool success, String message})> track({
    required String action,
    required int transactionId,
    required String bCoCo,
    required String byy,
    required String bchr,
    required int bNo,
    required int empCd,
    int? pauseReasonId,
  });

  /// Same endpoint as [track], but for the "No Work" action (`action: "N"`)
  /// only — that call takes just `action`/`empCd`, none of [track]'s other
  /// required fields.
  Future<({bool success, String message})> trackNoWork({required int empCd});
}
