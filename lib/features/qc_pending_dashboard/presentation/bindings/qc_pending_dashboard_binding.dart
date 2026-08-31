import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../data/datasources/qc_action_submit_data_source.dart';
import '../../data/datasources/qc_action_submit_remote_data_source_impl.dart';
import '../../data/datasources/qc_bag_list_data_source.dart';
import '../../data/datasources/qc_bag_list_remote_data_source_impl.dart';
import '../../data/datasources/qc_department_data_source.dart';
import '../../data/datasources/qc_department_remote_data_source_impl.dart';
import '../../data/datasources/qc_emp_list_data_source.dart';
import '../../data/datasources/qc_emp_list_remote_data_source_impl.dart';
import '../../data/datasources/qc_repair_list_data_source.dart';
import '../../data/datasources/qc_repair_list_remote_data_source_impl.dart';
import '../../data/repositories/qc_check_repository_impl.dart';
import '../../domain/repositories/qc_check_repository.dart';
import '../../domain/usecases/get_departments_usecase.dart';
import '../../domain/usecases/get_qc_checks_usecase.dart';
import '../controllers/qc_pending_dashboard_controller.dart';

class QcPendingDashboardBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();
    Get.lazyPut<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()));

    // Always the live QCDeptList/DeptQCPendingEmpList/QcPendingBagList/
    // QCRepairList/BagFinalReceive endpoints — no mock variant exists for
    // any of them, even when AppConfig.useMockData is true for the rest of
    // this feature.
    Get.lazyPut<QcDepartmentDataSource>(() => QcDepartmentRemoteDataSourceImpl(Get.find<ApiClient>()));
    Get.lazyPut<QcEmpListDataSource>(() => QcEmpListRemoteDataSourceImpl(Get.find<ApiClient>()));
    Get.lazyPut<QcBagListDataSource>(() => QcBagListRemoteDataSourceImpl(Get.find<ApiClient>()));
    Get.lazyPut<QcRepairListDataSource>(() => QcRepairListRemoteDataSourceImpl(Get.find<ApiClient>()));
    Get.lazyPut<QcActionSubmitDataSource>(() => QcActionSubmitRemoteDataSourceImpl(Get.find<ApiClient>()));

    Get.lazyPut<QcCheckRepository>(
      () => QcCheckRepositoryImpl(
        Get.find<QcDepartmentDataSource>(),
        Get.find<QcEmpListDataSource>(),
        Get.find<QcBagListDataSource>(),
        Get.find<QcRepairListDataSource>(),
        Get.find<QcActionSubmitDataSource>(),
      ),
    );
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
