import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../data/datasources/bag_data_source.dart';
import '../../data/datasources/bag_mock_data_source_impl.dart';
import '../../data/datasources/bag_remote_data_source_impl.dart';
import '../../data/repositories/bag_repository_impl.dart';
import '../../domain/repositories/bag_repository.dart';
import '../../domain/usecases/get_bags_usecase.dart';
import '../controllers/bag_list_controller.dart';

class BagListBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();

    Get.lazyPut<BagDataSource>(
      () => AppConfig.useMockBagList ? BagMockDataSourceImpl() : BagRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<BagRepository>(() => BagRepositoryImpl(Get.find<BagDataSource>()));
    Get.lazyPut<GetBagsUseCase>(() => GetBagsUseCase(Get.find<BagRepository>()));
    Get.lazyPut<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<BagListController>(
      () => BagListController(Get.find<GetBagsUseCase>(), Get.find<GetCurrentEmployeeUseCase>()),
    );
  }
}
