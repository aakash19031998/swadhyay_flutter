import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../data/datasources/timing_report_data_source.dart';
import '../../data/datasources/timing_report_remote_data_source_impl.dart';
import '../../data/repositories/timing_report_repository_impl.dart';
import '../../domain/repositories/timing_report_repository.dart';
import '../../domain/usecases/get_timing_report_usecase.dart';
import '../controllers/timing_report_controller.dart';

class TimingReportBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();

    Get.lazyPut<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()));

    Get.lazyPut<TimingReportDataSource>(
      () => TimingReportRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<TimingReportRepository>(() => TimingReportRepositoryImpl(Get.find<TimingReportDataSource>()));
    Get.lazyPut<GetTimingReportUseCase>(() => GetTimingReportUseCase(Get.find<TimingReportRepository>()));
    Get.lazyPut<TimingReportController>(
      () => TimingReportController(Get.find<GetTimingReportUseCase>(), Get.find<GetCurrentEmployeeUseCase>()),
    );
  }
}
