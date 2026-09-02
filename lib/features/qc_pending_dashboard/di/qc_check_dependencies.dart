import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/qc_action_submit_data_source.dart';
import '../data/datasources/qc_action_submit_remote_data_source_impl.dart';
import '../data/datasources/qc_bag_list_data_source.dart';
import '../data/datasources/qc_bag_list_remote_data_source_impl.dart';
import '../data/datasources/qc_department_data_source.dart';
import '../data/datasources/qc_department_remote_data_source_impl.dart';
import '../data/datasources/qc_emp_list_data_source.dart';
import '../data/datasources/qc_emp_list_remote_data_source_impl.dart';
import '../data/datasources/qc_repair_list_data_source.dart';
import '../data/datasources/qc_repair_list_remote_data_source_impl.dart';
import '../data/repositories/qc_check_repository_impl.dart';
import '../domain/repositories/qc_check_repository.dart';

/// Registers [QcCheckRepository] (and the five data sources
/// `QcCheckRepositoryImpl` needs to construct) as an app-lifetime
/// singleton.
///
/// Shared by `QcPendingDashboardBinding`, `QcBagListBinding`, and
/// `QcCheckerBagDetailBinding` — each screen only calls a subset of
/// [QcCheckRepository]'s methods, but the repository's constructor always
/// needs all five data sources. Whichever screen is entered first performs
/// the registration; the others simply find the existing instance. Same
/// idempotent pattern as `AuthDependencies`/`BagTimeTrackingDependencies`.
/// Always the live QCDeptList/DeptQCPendingEmpList/QcPendingBagList/
/// QCRepairList/BagFinalReceive endpoints — no mock variant exists for any
/// of them.
class QcCheckDependencies {
  const QcCheckDependencies._();

  static void ensureRegistered() {
    if (Get.isRegistered<QcCheckRepository>()) return;

    Get.put<QcDepartmentDataSource>(
      QcDepartmentRemoteDataSourceImpl(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<QcEmpListDataSource>(
      QcEmpListRemoteDataSourceImpl(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<QcBagListDataSource>(
      QcBagListRemoteDataSourceImpl(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<QcRepairListDataSource>(
      QcRepairListRemoteDataSourceImpl(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<QcActionSubmitDataSource>(
      QcActionSubmitRemoteDataSourceImpl(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<QcCheckRepository>(
      QcCheckRepositoryImpl(
        Get.find<QcDepartmentDataSource>(),
        Get.find<QcEmpListDataSource>(),
        Get.find<QcBagListDataSource>(),
        Get.find<QcRepairListDataSource>(),
        Get.find<QcActionSubmitDataSource>(),
      ),
      permanent: true,
    );
  }
}
