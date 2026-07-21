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
  Future<Either<Failure, List<ArtistProductionEntity>>> getProduction({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final entries = await _dataSource.getProduction(fromDate: fromDate, toDate: toDate);
      return Right(entries);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
