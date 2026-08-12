import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/design_master_data_source.dart';
import '../../data/datasources/design_master_remote_data_source_impl.dart';
import '../../data/repositories/design_master_repository_impl.dart';
import '../../domain/repositories/design_master_repository.dart';
import '../../domain/usecases/get_design_master_usecase.dart';
import '../controllers/design_image_controller.dart';

class DesignImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DesignMasterDataSource>(() => DesignMasterRemoteDataSourceImpl(Get.find<ApiClient>()));
    Get.lazyPut<DesignMasterRepository>(() => DesignMasterRepositoryImpl(Get.find<DesignMasterDataSource>()));
    Get.lazyPut<GetDesignMasterUseCase>(() => GetDesignMasterUseCase(Get.find<DesignMasterRepository>()));
    Get.lazyPut<DesignImageController>(() => DesignImageController(Get.find<GetDesignMasterUseCase>()));
  }
}
