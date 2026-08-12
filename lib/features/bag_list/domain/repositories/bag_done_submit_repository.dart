import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class BagDoneSubmitRepository {
  /// The right side's `success` reflects the response's own `status` field
  /// — a `false` status is a normal, valid rejection to surface via
  /// `message`, not a [Failure]. [Failure] is reserved for the request
  /// itself not going through (network/server error).
  Future<Either<Failure, ({bool success, String message})>> submit({
    required String trnId,
    required String proId,
    required String empCd,
  });
}
