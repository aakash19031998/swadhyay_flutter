import 'package:get/get.dart';

import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_kpi_detail_usecase.dart';
import '../controllers/dashboard_kpi_detail_args.dart';
import '../controllers/dashboard_kpi_detail_controller.dart';

/// Reuses the [DashboardRepository] [DashboardBinding] already registered —
/// this screen is only ever pushed on top of the Dashboard, which stays on
/// the nav stack underneath it, so that registration is still alive.
class DashboardKpiDetailBinding extends Bindings {
  @override
  void dependencies() {
    final DashboardKpiDetailArgs args = Get.arguments as DashboardKpiDetailArgs;

    Get.lazyPut<GetDashboardKpiDetailUseCase>(
      () => GetDashboardKpiDetailUseCase(Get.find<DashboardRepository>()),
    );
    Get.lazyPut<DashboardKpiDetailController>(
      () => DashboardKpiDetailController(
        Get.find<GetDashboardKpiDetailUseCase>(),
        args,
      ),
    );
  }
}
