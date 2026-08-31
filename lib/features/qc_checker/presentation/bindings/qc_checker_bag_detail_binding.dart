import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../../qc_pending_dashboard/data/datasources/qc_action_submit_data_source.dart';
import '../../../qc_pending_dashboard/data/datasources/qc_action_submit_remote_data_source_impl.dart';
import '../../../qc_pending_dashboard/data/datasources/qc_bag_list_data_source.dart';
import '../../../qc_pending_dashboard/data/datasources/qc_bag_list_remote_data_source_impl.dart';
import '../../../qc_pending_dashboard/data/datasources/qc_department_data_source.dart';
import '../../../qc_pending_dashboard/data/datasources/qc_department_remote_data_source_impl.dart';
import '../../../qc_pending_dashboard/data/datasources/qc_emp_list_data_source.dart';
import '../../../qc_pending_dashboard/data/datasources/qc_emp_list_remote_data_source_impl.dart';
import '../../../qc_pending_dashboard/data/datasources/qc_repair_list_data_source.dart';
import '../../../qc_pending_dashboard/data/datasources/qc_repair_list_remote_data_source_impl.dart';
import '../../../qc_pending_dashboard/data/repositories/qc_check_repository_impl.dart';
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
    Get.lazyPut<GetCurrentEmployeeUseCase>(
      () => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<QcDepartmentDataSource>(
      () => QcDepartmentRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<QcEmpListDataSource>(
      () => QcEmpListRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<QcBagListDataSource>(
      () => QcBagListRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<QcRepairListDataSource>(
      () => QcRepairListRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<QcActionSubmitDataSource>(
      () => QcActionSubmitRemoteDataSourceImpl(Get.find<ApiClient>()),
    );

    Get.lazyPut<QcCheckRepository>(
      () => QcCheckRepositoryImpl(
        Get.find<QcDepartmentDataSource>(),
        Get.find<QcEmpListDataSource>(),
        Get.find<QcBagListDataSource>(),
        Get.find<QcRepairListDataSource>(),
        Get.find<QcActionSubmitDataSource>(),
      ),
    );
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
