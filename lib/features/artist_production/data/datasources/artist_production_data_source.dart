import '../models/artist_production_model.dart';

abstract class ArtistProductionDataSource {
  Future<List<ArtistProductionModel>> getProduction({
    required DateTime fromDate,
    required DateTime toDate,
  });
}
