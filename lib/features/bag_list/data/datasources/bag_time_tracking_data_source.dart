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
}
