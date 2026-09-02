import 'package:get/get.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../../qc_pending_dashboard/di/qc_check_dependencies.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_assigned_bag_entity.dart';
import '../../../qc_pending_dashboard/domain/repositories/qc_check_repository.dart';
import '../../../qc_pending_dashboard/domain/usecases/get_qc_repair_checklist_usecase.dart';
import '../../../qc_pending_dashboard/domain/usecases/submit_qc_action_usecase.dart';
import '../controllers/qc_checker_bag_detail_controller.dart';

/// Reuses the same `QcCheckRepository`/`QcCheckRepositoryImpl` as
/// `QcCheckerBinding`/`QcBagListBinding` — this screen only ever calls
/// `getRepairChecklist`/`submitAction` on it, but the shared repository's
/// constructor still needs all five data sources registered to build (same
/// tradeoff already accepted in `QcBagListBinding`).
class QcCheckerBagDetailBinding extends Bindings {
  @override
  void dependencies() {
    final QcAssignedBagEntity bag = Get.arguments as QcAssignedBagEntity;

    AuthDependencies.ensureRegistered();
    QcCheckDependencies.ensureRegistered();

    Get.lazyPut<GetQcRepairChecklistUseCase>(
      () => GetQcRepairChecklistUseCase(Get.find<QcCheckRepository>()),
    );
    Get.lazyPut<SubmitQcActionUseCase>(
      () => SubmitQcActionUseCase(Get.find<QcCheckRepository>()),
    );

    Get.lazyPut<QcCheckerBagDetailController>(
      () => QcCheckerBagDetailController(
        Get.find<GetQcRepairChecklistUseCase>(),
        Get.find<SubmitQcActionUseCase>(),
        Get.find<GetCurrentEmployeeUseCase>(),
        Get.find<LocalStorageService>(),
        bag: bag,
      ),
    );
  }
}
