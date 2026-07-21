import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/design_image_data_source.dart';
import '../../data/datasources/design_image_mock_data_source_impl.dart';
import '../../data/datasources/design_image_remote_data_source_impl.dart';
import '../../data/repositories/design_image_repository_impl.dart';
import '../../domain/repositories/design_image_repository.dart';
import '../../domain/usecases/get_design_images_usecase.dart';
import '../controllers/design_image_controller.dart';

class DesignImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DesignImageDataSource>(
      () => AppConfig.useMockData
          ? DesignImageMockDataSourceImpl()
          : DesignImageRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<DesignImageRepository>(() => DesignImageRepositoryImpl(Get.find<DesignImageDataSource>()));
    Get.lazyPut<GetDesignImagesUseCase>(() => GetDesignImagesUseCase(Get.find<DesignImageRepository>()));
    Get.lazyPut<DesignImageController>(() => DesignImageController(Get.find<GetDesignImagesUseCase>()));
  }
}
