import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/brand_specification_data_source.dart';
import '../../data/datasources/brand_specification_remote_data_source_impl.dart';
import '../../data/repositories/brand_specification_repository_impl.dart';
import '../../domain/repositories/brand_specification_repository.dart';
import '../../domain/usecases/get_brand_specifications_usecase.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../../domain/usecases/get_specification_pdf_url_usecase.dart';
import '../controllers/brand_specification_controller.dart';

class BrandSpecificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BrandSpecificationDataSource>(
      () => BrandSpecificationRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<BrandSpecificationRepository>(
      () => BrandSpecificationRepositoryImpl(Get.find<BrandSpecificationDataSource>()),
    );
    Get.lazyPut<GetBrandsUseCase>(() => GetBrandsUseCase(Get.find<BrandSpecificationRepository>()));
    Get.lazyPut<GetBrandSpecificationsUseCase>(
      () => GetBrandSpecificationsUseCase(Get.find<BrandSpecificationRepository>()),
    );
    Get.lazyPut<GetSpecificationPdfUrlUseCase>(
      () => GetSpecificationPdfUrlUseCase(Get.find<BrandSpecificationRepository>()),
    );
    Get.lazyPut<BrandSpecificationController>(
      () => BrandSpecificationController(
        Get.find<GetBrandsUseCase>(),
        Get.find<GetBrandSpecificationsUseCase>(),
        Get.find<GetSpecificationPdfUrlUseCase>(),
      ),
    );
  }
}
