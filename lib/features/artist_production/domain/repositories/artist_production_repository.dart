import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/artist_production_entity.dart';

abstract class ArtistProductionRepository {
  Future<Either<Failure, List<ArtistProductionEntity>>> getProduction({
    required DateTime fromDate,
    required DateTime toDate,
  });
}
