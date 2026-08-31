import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../../bag_list/data/datasources/bag_media_gallery_data_source.dart';
import '../../../bag_list/data/datasources/bag_media_gallery_remote_data_source_impl.dart';
import '../../../bag_list/data/repositories/bag_media_gallery_repository_impl.dart';
import '../../../bag_list/domain/repositories/bag_media_gallery_repository.dart';
import '../../../bag_list/domain/usecases/get_bag_media_usecase.dart';
import '../../data/datasources/qc_checker_bag_search_data_source.dart';
import '../../data/datasources/qc_checker_bag_search_remote_data_source_impl.dart';
import '../../data/datasources/qc_checker_department_data_source.dart';
import '../../data/datasources/qc_checker_department_remote_data_source_impl.dart';
import '../../data/repositories/qc_checker_bag_search_repository_impl.dart';
import '../../data/repositories/qc_checker_department_repository_impl.dart';
import '../../domain/repositories/qc_checker_bag_search_repository.dart';
import '../../domain/repositories/qc_checker_department_repository.dart';
import '../../domain/usecases/get_qc_checker_departments_usecase.dart';
import '../../domain/usecases/search_qc_checker_bag_usecase.dart';
import '../controllers/qc_checker_controller.dart';

/// The QC Checker screen's own department-list (`QCDepartmentN`) and bag
/// search (`QCPendingBagSingle`) integrations — lean, single-purpose
/// datasource/repository/usecase trios, instead of reusing the QC Pending
/// Dashboard's `QcCheckRepository`/`QCDeptList`/`QcPendingBagList` (see
/// `QcDepartmentRemoteDataSourceImpl`/`QcBagListRemoteDataSourceImpl`),
/// neither of which this screen calls.
class QcCheckerBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();
    Get.lazyPut<GetCurrentEmployeeUseCase>(
      () => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<QcCheckerDepartmentDataSource>(
      () => QcCheckerDepartmentRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<QcCheckerDepartmentRepository>(
      () => QcCheckerDepartmentRepositoryImpl(
        Get.find<QcCheckerDepartmentDataSource>(),
      ),
    );
    Get.lazyPut<GetQcCheckerDepartmentsUseCase>(
      () => GetQcCheckerDepartmentsUseCase(
        Get.find<QcCheckerDepartmentRepository>(),
      ),
    );

    Get.lazyPut<QcCheckerBagSearchDataSource>(
      () => QcCheckerBagSearchRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<QcCheckerBagSearchRepository>(
      () => QcCheckerBagSearchRepositoryImpl(
        Get.find<QcCheckerBagSearchDataSource>(),
      ),
    );
    Get.lazyPut<SearchQcCheckerBagUseCase>(
      () => SearchQcCheckerBagUseCase(Get.find<QcCheckerBagSearchRepository>()),
    );

    // Reuses the app's one shared media viewer (`ImageAndVideoUrls`) — same
    // trio `QcBagListBinding` registers, not a QC-Checker-specific copy.
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

    Get.lazyPut<QcCheckerController>(
      () => QcCheckerController(
        Get.find<GetQcCheckerDepartmentsUseCase>(),
        Get.find<SearchQcCheckerBagUseCase>(),
        Get.find<GetBagMediaUseCase>(),
        Get.find<GetCurrentEmployeeUseCase>(),
        Get.find<LocalStorageService>(),
      ),
    );
  }
}
