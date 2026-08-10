import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class BagTimeTrackingRepository {
  /// `action` is `"S"` (Start), `"P"` (Pause) or `"R"` (Resume);
  /// `pauseReasonId` is only sent (non-null) for `"P"`.
  ///
  /// The right side's `success` reflects the response's own `status` field
  /// — a `false` status is a normal, valid outcome to surface via
  /// `message` (e.g. "bag already paused elsewhere"), not a [Failure].
  /// [Failure] is reserved for the request itself not going through
  /// (network/server error).
  Future<Either<Failure, ({bool success, String message})>> track({
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
