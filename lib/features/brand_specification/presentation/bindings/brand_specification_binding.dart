import 'package:get/get.dart';

import '../../data/datasources/brand_specification_data_source.dart';
import '../../data/datasources/brand_specification_mock_data_source_impl.dart';
import '../../data/repositories/brand_specification_repository_impl.dart';
import '../../domain/repositories/brand_specification_repository.dart';
import '../../domain/usecases/get_brand_specifications_usecase.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../controllers/brand_specification_controller.dart';

class BrandSpecificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BrandSpecificationDataSource>(() => BrandSpecificationMockDataSourceImpl());
    Get.lazyPut<BrandSpecificationRepository>(
      () => BrandSpecificationRepositoryImpl(Get.find<BrandSpecificationDataSource>()),
    );
    Get.lazyPut<GetBrandsUseCase>(() => GetBrandsUseCase(Get.find<BrandSpecificationRepository>()));
    Get.lazyPut<GetBrandSpecificationsUseCase>(
      () => GetBrandSpecificationsUseCase(Get.find<BrandSpecificationRepository>()),
    );
    Get.lazyPut<BrandSpecificationController>(
      () => BrandSpecificationController(
        Get.find<GetBrandsUseCase>(),
        Get.find<GetBrandSpecificationsUseCase>(),
      ),
    );
  }
}
