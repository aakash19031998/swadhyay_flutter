import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/timing_report_entity.dart';
import '../../domain/repositories/timing_report_repository.dart';
import '../datasources/timing_report_data_source.dart';

class TimingReportRepositoryImpl implements TimingReportRepository {
  TimingReportRepositoryImpl(this._dataSource);

  final TimingReportDataSource _dataSource;

  @override
  Future<Either<Failure, List<TimingReportEntity>>> getReport({required String empCd}) async {
    try {
      final entries = await _dataSource.getReport(empCd: empCd);
      return Right(entries);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
