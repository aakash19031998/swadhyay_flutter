import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/qc_check_data_source.dart';
import '../../data/datasources/qc_check_mock_data_source_impl.dart';
import '../../data/datasources/qc_check_remote_data_source_impl.dart';
import '../../data/repositories/qc_check_repository_impl.dart';
import '../../domain/repositories/qc_check_repository.dart';
import '../../domain/usecases/get_qc_checks_usecase.dart';
import '../controllers/qc_checking_controller.dart';

class QcCheckingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QcCheckDataSource>(
      () => AppConfig.useMockData
          ? QcCheckMockDataSourceImpl()
          : QcCheckRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<QcCheckRepository>(() => QcCheckRepositoryImpl(Get.find<QcCheckDataSource>()));
    Get.lazyPut<GetQcChecksUseCase>(() => GetQcChecksUseCase(Get.find<QcCheckRepository>()));
    Get.lazyPut<QcCheckingController>(() => QcCheckingController(Get.find<GetQcChecksUseCase>()));
  }
}
