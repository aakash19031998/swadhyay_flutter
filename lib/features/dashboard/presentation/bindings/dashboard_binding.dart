import 'package:get/get.dart';

import '../../data/datasources/dashboard_data_source.dart';
import '../../data/datasources/dashboard_mock_data_source_impl.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_departments_usecase.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // No real backend yet — always the mock data source (see
    // DashboardDataSource's own doc comment). Swapping in a live one later
    // is a one-line change here, same as every other feature's binding.
    Get.lazyPut<DashboardDataSource>(() => DashboardMockDataSourceImpl());
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepositoryImpl(Get.find<DashboardDataSource>()),
    );
    Get.lazyPut<GetDashboardDepartmentsUseCase>(
      () => GetDashboardDepartmentsUseCase(Get.find<DashboardRepository>()),
    );
    Get.lazyPut<GetDashboardSummaryUseCase>(
      () => GetDashboardSummaryUseCase(Get.find<DashboardRepository>()),
    );
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        Get.find<GetDashboardDepartmentsUseCase>(),
        Get.find<GetDashboardSummaryUseCase>(),
      ),
    );
  }
}
