abstract class DummyAddBtnValidationDataSource {
  Future<({bool success, String message})> validate({
    required String empCd,
    required int setId,
    required int inputQty,
    required int emrPcs,
    required int emrStone,
  });
}
