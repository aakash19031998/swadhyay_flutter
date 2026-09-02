import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../bag_list/data/datasources/bag_media_gallery_data_source.dart';
import '../../../bag_list/data/datasources/bag_media_gallery_remote_data_source_impl.dart';
import '../../../bag_list/data/repositories/bag_media_gallery_repository_impl.dart';
import '../../../bag_list/domain/repositories/bag_media_gallery_repository.dart';
import '../../../bag_list/domain/usecases/get_bag_media_usecase.dart';
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
import '../../domain/usecases/get_qc_assigned_bags_usecase.dart';
import '../controllers/qc_bag_list_args.dart';
import '../controllers/qc_bag_list_controller.dart';

class QcBagListBinding extends Bindings {
  @override
  void dependencies() {
    final QcBagListArgs args = Get.arguments as QcBagListArgs;

    AuthDependencies.ensureRegistered();

    // This screen never calls getDepartments()/getChecks()/
    // getRepairChecklist()/submitAction(), but QcCheckRepositoryImpl still
    // needs all five injected to construct — always the live QCDeptList/
    // DeptQCPendingEmpList/QcPendingBagList/QCRepairList/BagFinalReceive
    // endpoints, same as QcPendingDashboardBinding.
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
    Get.lazyPut<GetQcAssignedBagsUseCase>(
      () => GetQcAssignedBagsUseCase(Get.find<QcCheckRepository>()),
    );

    // Always the live ImageAndVideoUrls endpoint — same "no mock, always
    // remote" pattern as the rest of this feature's data sources.
    Get.lazyPut<BagMediaGalleryDataSource>(
      () => BagMediaGalleryRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<BagMediaGalleryRepository>(
      () =>
          BagMediaGalleryRepositoryImpl(Get.find<BagMediaGalleryDataSource>()),
    );
    Get.lazyPut<GetBagMediaUseCase>(
      () => GetBagMediaUseCase(Get.find<BagMediaGalleryRepository>()),
    );

    Get.lazyPut<QcBagListController>(
      () => QcBagListController(
        Get.find<GetQcAssignedBagsUseCase>(),
        Get.find<GetBagMediaUseCase>(),
        empCode: args.empCode,
        empName: args.empName,
        totalBags: args.totalBags,
        totalPieces: args.totalPieces,
        imageUrl: args.imageUrl,
      ),
    );
  }
}
