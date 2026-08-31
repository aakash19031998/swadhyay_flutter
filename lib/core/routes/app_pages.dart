import 'package:get/get.dart';

import '../../features/artist_production/presentation/bindings/artist_production_binding.dart';
import '../../features/artist_production/presentation/views/artist_production_view.dart';
import '../../features/authentication/presentation/bindings/login_binding.dart';
import '../../features/brand_specification/presentation/bindings/brand_pdf_viewer_binding.dart';
import '../../features/brand_specification/presentation/bindings/brand_specification_binding.dart';
import '../../features/brand_specification/presentation/views/brand_pdf_viewer_view.dart';
import '../../features/brand_specification/presentation/views/brand_specification_view.dart';
import '../../features/authentication/presentation/views/login_view.dart';
import '../../features/bag_list/presentation/bindings/bag_completion_binding.dart';
import '../../features/bag_list/presentation/bindings/bag_detail_binding.dart';
import '../../features/bag_list/presentation/bindings/bag_list_binding.dart';
import '../../features/bag_list/presentation/bindings/bag_media_viewer_binding.dart';
import '../../features/bag_list/presentation/bindings/bag_scanner_binding.dart';
import '../../features/bag_list/presentation/views/bag_completion_view.dart';
import '../../features/bag_list/presentation/views/bag_detail_view.dart';
import '../../features/bag_list/presentation/views/bag_list_view.dart';
import '../../features/bag_list/presentation/views/bag_media_viewer_view.dart';
import '../../features/bag_list/presentation/views/bag_scanner_view.dart';
import '../../features/change_password/presentation/bindings/change_password_binding.dart';
import '../../features/change_password/presentation/views/change_password_view.dart';
import '../../features/design_image/presentation/bindings/design_image_binding.dart';
import '../../features/design_image/presentation/views/design_image_view.dart';
import '../../features/home/presentation/bindings/home_binding.dart';
import '../../features/home/presentation/views/home_view.dart';
import '../../features/profile/presentation/bindings/profile_binding.dart';
import '../../features/profile/presentation/views/profile_view.dart';
import '../../features/qc_checker/presentation/bindings/qc_checker_bag_detail_binding.dart';
import '../../features/qc_checker/presentation/bindings/qc_checker_binding.dart';
import '../../features/qc_checker/presentation/views/qc_checker_bag_detail_view.dart';
import '../../features/qc_checker/presentation/views/qc_checker_view.dart';
import '../../features/qc_pending_dashboard/presentation/bindings/qc_bag_list_binding.dart';
import '../../features/qc_pending_dashboard/presentation/bindings/qc_pending_dashboard_binding.dart';
import '../../features/qc_pending_dashboard/presentation/views/qc_bag_list_view.dart';
import '../../features/qc_pending_dashboard/presentation/views/qc_pending_dashboard_view.dart';
import '../../features/splash/presentation/bindings/splash_binding.dart';
import '../../features/splash/presentation/views/splash_view.dart';
import '../../features/timing_report/presentation/bindings/timing_report_binding.dart';
import '../../features/timing_report/presentation/views/timing_report_view.dart';
import 'app_routes.dart';

/// Central route table. Every destination in the app is registered here,
/// each paired with the [Bindings] that wires its dependencies — nothing
/// else constructs a controller directly.
class AppPages {
  const AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.bagList,
      page: () => const BagListView(),
      binding: BagListBinding(),
    ),
    GetPage(
      name: AppRoutes.bagMediaViewer,
      page: () => const BagMediaViewerView(),
      binding: BagMediaViewerBinding(),
    ),
    GetPage(
      name: AppRoutes.bagDetail,
      page: () => const BagDetailView(),
      binding: BagDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.bagCompletion,
      page: () => const BagCompletionView(),
      binding: BagCompletionBinding(),
    ),
    GetPage(
      name: AppRoutes.bagScanner,
      page: () => const BagScannerView(),
      binding: BagScannerBinding(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.designImage,
      page: () => const DesignImageView(),
      binding: DesignImageBinding(),
    ),
    GetPage(
      name: AppRoutes.qcPendingDashboard,
      page: () => const QcPendingDashboardView(),
      binding: QcPendingDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.qcChecker,
      page: () => const QcCheckerView(),
      binding: QcCheckerBinding(),
    ),
    GetPage(
      name: AppRoutes.qcCheckerBagDetail,
      page: () => const QcCheckerBagDetailView(),
      binding: QcCheckerBagDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.qcBagList,
      page: () => const QcBagListView(),
      binding: QcBagListBinding(),
    ),
    GetPage(
      name: AppRoutes.timingReport,
      page: () => const TimingReportView(),
      binding: TimingReportBinding(),
    ),
    GetPage(
      name: AppRoutes.artistProduction,
      page: () => const ArtistProductionView(),
      binding: ArtistProductionBinding(),
    ),
    GetPage(
      name: AppRoutes.brandSpecification,
      page: () => const BrandSpecificationView(),
      binding: BrandSpecificationBinding(),
    ),
    GetPage(
      name: AppRoutes.brandSpecificationPdfViewer,
      page: () => const BrandPdfViewerView(),
      binding: BrandPdfViewerBinding(),
    ),
  ];
}
