import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/skip_bag_data_source.dart';
import '../../data/datasources/skip_bag_mock_data_source_impl.dart';
import '../../data/datasources/skip_bag_remote_data_source_impl.dart';
import '../../data/repositories/skip_bag_repository_impl.dart';
import '../../domain/repositories/skip_bag_repository.dart';
import '../../domain/usecases/get_skipped_bags_usecase.dart';
import '../../domain/usecases/skip_bag_usecase.dart';
import '../controllers/skip_bag_controller.dart';

class SkipBagBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SkipBagDataSource>(
      () => AppConfig.useMockData
          ? SkipBagMockDataSourceImpl()
          : SkipBagRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<SkipBagRepository>(() => SkipBagRepositoryImpl(Get.find<SkipBagDataSource>()));
    Get.lazyPut<GetSkippedBagsUseCase>(() => GetSkippedBagsUseCase(Get.find<SkipBagRepository>()));
    Get.lazyPut<SkipBagUseCase>(() => SkipBagUseCase(Get.find<SkipBagRepository>()));
    Get.lazyPut<SkipBagController>(
      () => SkipBagController(Get.find<GetSkippedBagsUseCase>(), Get.find<SkipBagUseCase>()),
    );
  }
}
