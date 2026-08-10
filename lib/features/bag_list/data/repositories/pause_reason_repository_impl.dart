import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pause_reason_entity.dart';
import '../../domain/repositories/pause_reason_repository.dart';
import '../datasources/pause_reason_data_source.dart';

class PauseReasonRepositoryImpl implements PauseReasonRepository {
  PauseReasonRepositoryImpl(this._dataSource);

  final PauseReasonDataSource _dataSource;

  @override
  Future<Either<Failure, List<PauseReasonEntity>>> getReasons() async {
    try {
      final reasons = await _dataSource.getReasons();
      return Right(reasons);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
