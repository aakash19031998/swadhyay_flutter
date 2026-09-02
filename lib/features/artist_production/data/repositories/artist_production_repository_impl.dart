import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
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
  }) {
    return guard(() async {
      final report = await _dataSource.getProduction(fromDate: fromDate, toDate: toDate, empCd: empCd);
      return report;
    });
  }
}
