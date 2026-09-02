import 'package:get/get.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../di/qc_check_dependencies.dart';
import '../../domain/repositories/qc_check_repository.dart';
import '../../domain/usecases/get_departments_usecase.dart';
import '../../domain/usecases/get_qc_checks_usecase.dart';
import '../controllers/qc_pending_dashboard_controller.dart';

class QcPendingDashboardBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();
    QcCheckDependencies.ensureRegistered();

    Get.lazyPut<GetQcChecksUseCase>(() => GetQcChecksUseCase(Get.find<QcCheckRepository>()));
    Get.lazyPut<GetDepartmentsUseCase>(() => GetDepartmentsUseCase(Get.find<QcCheckRepository>()));
    Get.lazyPut<QcPendingDashboardController>(
      () => QcPendingDashboardController(
        Get.find<GetQcChecksUseCase>(),
        Get.find<GetDepartmentsUseCase>(),
        Get.find<GetCurrentEmployeeUseCase>(),
        Get.find<LocalStorageService>(),
      ),
    );
  }
}
