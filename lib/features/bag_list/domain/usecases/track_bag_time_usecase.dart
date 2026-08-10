import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/bag_time_tracking_repository.dart';

class TrackBagTimeUseCase {
  const TrackBagTimeUseCase(this._repository);

  final BagTimeTrackingRepository _repository;

  Future<Either<Failure, ({bool success, String message})>> call({
    required String action,
    required int transactionId,
    required String bCoCo,
    required String byy,
    required String bchr,
    required int bNo,
    required int empCd,
    int? pauseReasonId,
  }) {
    return _repository.track(
      action: action,
      transactionId: transactionId,
      bCoCo: bCoCo,
      byy: byy,
      bchr: bchr,
      bNo: bNo,
      empCd: empCd,
      pauseReasonId: pauseReasonId,
    );
  }
}
