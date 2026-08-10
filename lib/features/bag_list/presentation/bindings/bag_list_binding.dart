import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../data/datasources/bag_data_source.dart';
import '../../data/datasources/bag_media_gallery_data_source.dart';
import '../../data/datasources/bag_media_gallery_mock_data_source_impl.dart';
import '../../data/datasources/bag_media_gallery_remote_data_source_impl.dart';
import '../../data/datasources/bag_mock_data_source_impl.dart';
import '../../data/datasources/bag_remote_data_source_impl.dart';
import '../../data/repositories/bag_media_gallery_repository_impl.dart';
import '../../data/repositories/bag_repository_impl.dart';
import '../../di/bag_time_tracking_dependencies.dart';
import '../../di/pause_reason_dependencies.dart';
import '../../domain/repositories/bag_media_gallery_repository.dart';
import '../../domain/repositories/bag_repository.dart';
import '../../domain/usecases/get_bag_media_usecase.dart';
import '../../domain/usecases/get_bags_usecase.dart';
import '../controllers/bag_list_controller.dart';

class BagListBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();
    PauseReasonDependencies.ensureRegistered();
    BagTimeTrackingDependencies.ensureRegistered();

    Get.lazyPut<BagDataSource>(
      () => AppConfig.useMockBagList ? BagMockDataSourceImpl() : BagRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<BagRepository>(() => BagRepositoryImpl(Get.find<BagDataSource>()));
    Get.lazyPut<GetBagsUseCase>(() => GetBagsUseCase(Get.find<BagRepository>()));
    Get.lazyPut<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()));

    Get.lazyPut<BagMediaGalleryDataSource>(
      () => AppConfig.useMockBagMediaGallery
          ? BagMediaGalleryMockDataSourceImpl()
          : BagMediaGalleryRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<BagMediaGalleryRepository>(
      () => BagMediaGalleryRepositoryImpl(Get.find<BagMediaGalleryDataSource>()),
    );
    Get.lazyPut<GetBagMediaUseCase>(() => GetBagMediaUseCase(Get.find<BagMediaGalleryRepository>()));

    Get.lazyPut<BagListController>(
      () => BagListController(
        Get.find<GetBagsUseCase>(),
        Get.find<GetCurrentEmployeeUseCase>(),
        Get.find<GetBagMediaUseCase>(),
      ),
    );
  }
}
