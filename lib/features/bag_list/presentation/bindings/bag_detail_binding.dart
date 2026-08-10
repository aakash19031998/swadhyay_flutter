import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../data/datasources/bag_detail_data_source.dart';
import '../../data/datasources/bag_detail_remote_data_source_impl.dart';
import '../../data/datasources/bag_media_gallery_data_source.dart';
import '../../data/datasources/bag_media_gallery_mock_data_source_impl.dart';
import '../../data/datasources/bag_media_gallery_remote_data_source_impl.dart';
import '../../data/repositories/bag_detail_repository_impl.dart';
import '../../data/repositories/bag_media_gallery_repository_impl.dart';
import '../../di/bag_time_tracking_dependencies.dart';
import '../../di/pause_reason_dependencies.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/repositories/bag_detail_repository.dart';
import '../../domain/repositories/bag_media_gallery_repository.dart';
import '../../domain/usecases/get_bag_detail_usecase.dart';
import '../../domain/usecases/get_bag_media_usecase.dart';
import '../controllers/bag_detail_controller.dart';

class BagDetailBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();
    PauseReasonDependencies.ensureRegistered();
    BagTimeTrackingDependencies.ensureRegistered();

    final BagEntity bag = Get.arguments as BagEntity;

    Get.lazyPut<BagDetailDataSource>(
      () => BagDetailRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<BagDetailRepository>(() => BagDetailRepositoryImpl(Get.find<BagDetailDataSource>()));
    Get.lazyPut<GetBagDetailUseCase>(() => GetBagDetailUseCase(Get.find<BagDetailRepository>()));
    Get.lazyPut<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()));

    // Same image/video gallery API as the Bag List screen's thumbnail —
    // its own registration here since Get.lazyPut instances aren't shared
    // across separate page bindings.
    Get.lazyPut<BagMediaGalleryDataSource>(
      () => AppConfig.useMockBagMediaGallery
          ? BagMediaGalleryMockDataSourceImpl()
          : BagMediaGalleryRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<BagMediaGalleryRepository>(
      () => BagMediaGalleryRepositoryImpl(Get.find<BagMediaGalleryDataSource>()),
    );
    Get.lazyPut<GetBagMediaUseCase>(() => GetBagMediaUseCase(Get.find<BagMediaGalleryRepository>()));

    Get.put(
      BagDetailController(
        bag,
        Get.find<GetBagDetailUseCase>(),
        Get.find<GetCurrentEmployeeUseCase>(),
        Get.find<GetBagMediaUseCase>(),
      ),
    );
  }
}
