import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../data/datasources/bag_detail_data_source.dart';
import '../../data/datasources/bag_detail_remote_data_source_impl.dart';
import '../../data/repositories/bag_detail_repository_impl.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/repositories/bag_detail_repository.dart';
import '../../domain/usecases/get_bag_detail_usecase.dart';
import '../controllers/bag_detail_controller.dart';

class BagDetailBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();

    final BagEntity bag = Get.arguments as BagEntity;

    Get.lazyPut<BagDetailDataSource>(
      () => BagDetailRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<BagDetailRepository>(() => BagDetailRepositoryImpl(Get.find<BagDetailDataSource>()));
    Get.lazyPut<GetBagDetailUseCase>(() => GetBagDetailUseCase(Get.find<BagDetailRepository>()));
    Get.lazyPut<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()));

    Get.put(
      BagDetailController(
        bag,
        Get.find<GetBagDetailUseCase>(),
        Get.find<GetCurrentEmployeeUseCase>(),
      ),
    );
  }
}
