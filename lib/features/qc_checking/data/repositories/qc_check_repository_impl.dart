import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/qc_check_entity.dart';
import '../../domain/repositories/qc_check_repository.dart';
import '../datasources/qc_check_data_source.dart';

class QcCheckRepositoryImpl implements QcCheckRepository {
  QcCheckRepositoryImpl(this._dataSource);

  final QcCheckDataSource _dataSource;

  @override
  Future<Either<Failure, List<QcCheckEntity>>> getChecks({String query = ''}) async {
    try {
      final checks = await _dataSource.getChecks(query: query);
      return Right(checks);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
