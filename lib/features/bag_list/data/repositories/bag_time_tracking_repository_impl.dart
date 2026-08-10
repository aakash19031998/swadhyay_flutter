import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/bag_time_tracking_repository.dart';
import '../datasources/bag_time_tracking_data_source.dart';

class BagTimeTrackingRepositoryImpl implements BagTimeTrackingRepository {
  BagTimeTrackingRepositoryImpl(this._dataSource);

  final BagTimeTrackingDataSource _dataSource;

  @override
  Future<Either<Failure, ({bool success, String message})>> track({
    required String action,
    required int transactionId,
    required String bCoCo,
    required String byy,
    required String bchr,
    required int bNo,
    required int empCd,
    int? pauseReasonId,
  }) async {
    try {
      final result = await _dataSource.track(
        action: action,
        transactionId: transactionId,
        bCoCo: bCoCo,
        byy: byy,
        bchr: bchr,
        bNo: bNo,
        empCd: empCd,
        pauseReasonId: pauseReasonId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
