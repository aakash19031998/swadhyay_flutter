import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/folloper_report_entity.dart';
import '../../domain/repositories/folloper_report_repository.dart';
import '../datasources/folloper_report_data_source.dart';

class FolloperReportRepositoryImpl implements FolloperReportRepository {
  FolloperReportRepositoryImpl(this._dataSource);

  final FolloperReportDataSource _dataSource;

  @override
  Future<Either<Failure, List<FolloperReportEntity>>> getReport({String query = ''}) async {
    try {
      final entries = await _dataSource.getReport(query: query);
      return Right(entries);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
