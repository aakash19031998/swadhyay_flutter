import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/artist_production_data_source.dart';
import '../../data/datasources/artist_production_mock_data_source_impl.dart';
import '../../data/datasources/artist_production_remote_data_source_impl.dart';
import '../../data/repositories/artist_production_repository_impl.dart';
import '../../domain/repositories/artist_production_repository.dart';
import '../../domain/usecases/get_artist_production_usecase.dart';
import '../controllers/artist_production_controller.dart';

class ArtistProductionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArtistProductionDataSource>(
      () => AppConfig.useMockData
          ? ArtistProductionMockDataSourceImpl()
          : ArtistProductionRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<ArtistProductionRepository>(
      () => ArtistProductionRepositoryImpl(Get.find<ArtistProductionDataSource>()),
    );
    Get.lazyPut<GetArtistProductionUseCase>(
      () => GetArtistProductionUseCase(Get.find<ArtistProductionRepository>()),
    );
    Get.lazyPut<ArtistProductionController>(
      () => ArtistProductionController(Get.find<GetArtistProductionUseCase>()),
    );
  }
}
