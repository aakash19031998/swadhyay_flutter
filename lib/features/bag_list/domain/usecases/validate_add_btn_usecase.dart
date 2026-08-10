import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/dummy_add_btn_validation_repository.dart';

class ValidateAddBtnUseCase {
  const ValidateAddBtnUseCase(this._repository);

  final DummyAddBtnValidationRepository _repository;

  Future<Either<Failure, ({bool success, String message})>> call({
    required String empCd,
    required int setId,
    required int inputQty,
    required int emrPcs,
    required int emrStone,
  }) {
    return _repository.validate(
      empCd: empCd,
      setId: setId,
      inputQty: inputQty,
      emrPcs: emrPcs,
      emrStone: emrStone,
    );
  }
}
