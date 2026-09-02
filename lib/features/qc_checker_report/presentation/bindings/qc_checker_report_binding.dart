import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../data/datasources/qc_checker_report_data_source.dart';
import '../../data/datasources/qc_checker_report_remote_data_source_impl.dart';
import '../../data/repositories/qc_checker_report_repository_impl.dart';
import '../../domain/repositories/qc_checker_report_repository.dart';
import '../../domain/usecases/get_qc_checker_report_usecase.dart';
import '../controllers/qc_checker_report_controller.dart';

class QcCheckerReportBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();

    Get.lazyPut<QcCheckerReportDataSource>(
      () => QcCheckerReportRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<QcCheckerReportRepository>(
      () =>
          QcCheckerReportRepositoryImpl(Get.find<QcCheckerReportDataSource>()),
    );
    Get.lazyPut<GetQcCheckerReportUseCase>(
      () => GetQcCheckerReportUseCase(Get.find<QcCheckerReportRepository>()),
    );
    Get.lazyPut<QcCheckerReportController>(
      () => QcCheckerReportController(
        Get.find<GetQcCheckerReportUseCase>(),
        Get.find<GetCurrentEmployeeUseCase>(),
      ),
    );
  }
}
