import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/artist_production_entity.dart';
import '../repositories/artist_production_repository.dart';

class GetArtistProductionUseCase {
  const GetArtistProductionUseCase(this._repository);

  final ArtistProductionRepository _repository;

  Future<Either<Failure, ArtistProductionReportEntity>> call({
    required DateTime fromDate,
    required DateTime toDate,
    required String empCd,
  }) {
    return _repository.getProduction(fromDate: fromDate, toDate: toDate, empCd: empCd);
  }
}
