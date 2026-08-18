/// Route name constants. Every `Get.toNamed` call and every [GetPage] in
/// `app_pages.dart` must reference these — never an inline string literal.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String bagList = '/bag-list';
  static const String bagMediaViewer = '/bag-list/media-viewer';
  static const String bagDetail = '/bag-list/detail';
  static const String bagCompletion = '/bag-list/completion';
  static const String bagScanner = '/bag-list/scanner';
  static const String skipBag = '/skip-bag';
  static const String changePassword = '/change-password';
  static const String designImage = '/reports/design-image';
  static const String qcChecking = '/reports/qc-checking';
  static const String timingReport = '/reports/timing-report';
  static const String artistProduction = '/reports/artist-production';
  static const String folloperReport = '/reports/folloper-report';
  static const String brandSpecification = '/brand-specification';
  static const String brandSpecificationPdfViewer = '/brand-specification/pdf-viewer';
}
