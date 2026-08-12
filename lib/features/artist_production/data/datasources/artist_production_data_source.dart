import '../models/artist_production_model.dart';

abstract class ArtistProductionDataSource {
  Future<ArtistProductionReportModel> getProduction({
    required DateTime fromDate,
    required DateTime toDate,
    required String empCd,
  });
}
