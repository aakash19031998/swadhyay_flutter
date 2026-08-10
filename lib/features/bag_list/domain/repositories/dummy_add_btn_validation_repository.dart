import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class DummyAddBtnValidationRepository {
  /// The right side's `success` reflects the response's own `status` field
  /// — a `false` status is a normal, valid outcome to surface via
  /// `message` (e.g. "Please Enter Proper Input Qty."), not a [Failure].
  /// [Failure] is reserved for the request itself not going through
  /// (network/server error).
  Future<Either<Failure, ({bool success, String message})>> validate({
    required String empCd,
    required int setId,
    required int inputQty,
    required int emrPcs,
    required int emrStone,
  });
}
