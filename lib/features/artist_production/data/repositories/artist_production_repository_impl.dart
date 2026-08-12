import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/artist_production_entity.dart';
import '../../domain/repositories/artist_production_repository.dart';
import '../datasources/artist_production_data_source.dart';

class ArtistProductionRepositoryImpl implements ArtistProductionRepository {
  ArtistProductionRepositoryImpl(this._dataSource);

  final ArtistProductionDataSource _dataSource;

  @override
  Future<Either<Failure, ArtistProductionReportEntity>> getProduction({
    required DateTime fromDate,
    required DateTime toDate,
    required String empCd,
  }) async {
    try {
      final report = await _dataSource.getProduction(fromDate: fromDate, toDate: toDate, empCd: empCd);
      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
