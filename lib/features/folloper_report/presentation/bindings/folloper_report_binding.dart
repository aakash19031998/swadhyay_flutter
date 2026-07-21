import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/folloper_report_data_source.dart';
import '../../data/datasources/folloper_report_mock_data_source_impl.dart';
import '../../data/datasources/folloper_report_remote_data_source_impl.dart';
import '../../data/repositories/folloper_report_repository_impl.dart';
import '../../domain/repositories/folloper_report_repository.dart';
import '../../domain/usecases/get_folloper_report_usecase.dart';
import '../controllers/folloper_report_controller.dart';

class FolloperReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FolloperReportDataSource>(
      () => AppConfig.useMockData
          ? FolloperReportMockDataSourceImpl()
          : FolloperReportRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<FolloperReportRepository>(
      () => FolloperReportRepositoryImpl(Get.find<FolloperReportDataSource>()),
    );
    Get.lazyPut<GetFolloperReportUseCase>(
      () => GetFolloperReportUseCase(Get.find<FolloperReportRepository>()),
    );
    Get.lazyPut<FolloperReportController>(
      () => FolloperReportController(Get.find<GetFolloperReportUseCase>()),
    );
  }
}
