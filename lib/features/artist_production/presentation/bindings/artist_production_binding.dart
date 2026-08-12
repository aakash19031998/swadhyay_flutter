import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../data/datasources/artist_production_data_source.dart';
import '../../data/datasources/artist_production_remote_data_source_impl.dart';
import '../../data/repositories/artist_production_repository_impl.dart';
import '../../domain/repositories/artist_production_repository.dart';
import '../../domain/usecases/get_artist_production_usecase.dart';
import '../controllers/artist_production_controller.dart';

class ArtistProductionBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();

    Get.lazyPut<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()));

    Get.lazyPut<ArtistProductionDataSource>(
      () => ArtistProductionRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<ArtistProductionRepository>(
      () => ArtistProductionRepositoryImpl(Get.find<ArtistProductionDataSource>()),
    );
    Get.lazyPut<GetArtistProductionUseCase>(
      () => GetArtistProductionUseCase(Get.find<ArtistProductionRepository>()),
    );
    Get.lazyPut<ArtistProductionController>(
      () => ArtistProductionController(
        Get.find<GetArtistProductionUseCase>(),
        Get.find<GetCurrentEmployeeUseCase>(),
      ),
    );
  }
}
