abstract class BagDoneSubmitDataSource {
  Future<({bool success, String message})> submit({
    required String trnId,
    required String proId,
    required String empCd,
  });
}
