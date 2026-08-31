import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/bag_time_tracking_repository.dart';

class TrackNoWorkUseCase {
  const TrackNoWorkUseCase(this._repository);

  final BagTimeTrackingRepository _repository;

  Future<Either<Failure, ({bool success, String message})>> call({required int empCd}) {
    return _repository.trackNoWork(empCd: empCd);
  }
}
