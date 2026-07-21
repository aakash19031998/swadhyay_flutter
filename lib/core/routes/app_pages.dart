import 'package:get/get.dart';

import '../../features/artist_production/presentation/bindings/artist_production_binding.dart';
import '../../features/artist_production/presentation/views/artist_production_view.dart';
import '../../features/authentication/presentation/bindings/login_binding.dart';
import '../../features/authentication/presentation/views/login_view.dart';
import '../../features/bag_list/presentation/bindings/bag_completion_binding.dart';
import '../../features/bag_list/presentation/bindings/bag_detail_binding.dart';
import '../../features/bag_list/presentation/bindings/bag_list_binding.dart';
import '../../features/bag_list/presentation/bindings/bag_media_viewer_binding.dart';
import '../../features/bag_list/presentation/views/bag_completion_view.dart';
import '../../features/bag_list/presentation/views/bag_detail_view.dart';
import '../../features/bag_list/presentation/views/bag_list_view.dart';
import '../../features/bag_list/presentation/views/bag_media_viewer_view.dart';
import '../../features/change_password/presentation/bindings/change_password_binding.dart';
import '../../features/change_password/presentation/views/change_password_view.dart';
import '../../features/design_image/presentation/bindings/design_image_binding.dart';
import '../../features/design_image/presentation/views/design_image_view.dart';
import '../../features/folloper_report/presentation/bindings/folloper_report_binding.dart';
import '../../features/folloper_report/presentation/views/folloper_report_view.dart';
import '../../features/home/presentation/bindings/home_binding.dart';
import '../../features/home/presentation/views/home_view.dart';
import '../../features/profile/presentation/bindings/profile_binding.dart';
import '../../features/profile/presentation/views/profile_view.dart';
import '../../features/qc_checking/presentation/bindings/qc_checking_binding.dart';
import '../../features/qc_checking/presentation/views/qc_checking_view.dart';
import '../../features/skip_bag/presentation/bindings/skip_bag_binding.dart';
import '../../features/skip_bag/presentation/views/skip_bag_view.dart';
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
      name: AppRoutes.skipBag,
      page: () => const SkipBagView(),
      binding: SkipBagBinding(),
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
      name: AppRoutes.qcChecking,
      page: () => const QcCheckingView(),
      binding: QcCheckingBinding(),
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
      name: AppRoutes.folloperReport,
      page: () => const FolloperReportView(),
      binding: FolloperReportBinding(),
    ),
  ];
}
