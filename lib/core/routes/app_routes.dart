/// Route name constants. Every `Get.toNamed` call and every [GetPage] in
/// `app_pages.dart` must reference these — never an inline string literal.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String dashboardKpiDetail = '/dashboard/kpi-detail';
  static const String profile = '/profile';
  static const String bagList = '/bag-list';
  static const String bagMediaViewer = '/bag-list/media-viewer';
  static const String bagDetail = '/bag-list/detail';
  static const String bagCompletion = '/bag-list/completion';
  static const String bagScanner = '/bag-list/scanner';
  static const String changePassword = '/change-password';
  static const String designImage = '/reports/design-image';
  static const String qcPendingDashboard = '/reports/qc-pending-dashboard';
  static const String qcChecker = '/reports/qc-checker';
  static const String qcCheckerBagDetail = '/reports/qc-checker/bag-detail';
  static const String qcBagList = '/reports/qc-pending-dashboard/bag-list';
  static const String timingReport = '/reports/timing-report';
  static const String artistProduction = '/reports/artist-production';
  static const String qcCheckerReport = '/reports/qc-checker-report';
  static const String brandSpecification = '/brand-specification';
  static const String brandSpecificationPdfViewer =
      '/brand-specification/pdf-viewer';
  static const String earnTillDate = '/earn-till-date';
}
