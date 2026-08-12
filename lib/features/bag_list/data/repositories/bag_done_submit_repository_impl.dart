import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/bag_done_submit_repository.dart';
import '../datasources/bag_done_submit_data_source.dart';

class BagDoneSubmitRepositoryImpl implements BagDoneSubmitRepository {
  BagDoneSubmitRepositoryImpl(this._dataSource);

  final BagDoneSubmitDataSource _dataSource;

  @override
  Future<Either<Failure, ({bool success, String message})>> submit({
    required String trnId,
    required String proId,
    required String empCd,
  }) async {
    try {
      final result = await _dataSource.submit(trnId: trnId, proId: proId, empCd: empCd);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
