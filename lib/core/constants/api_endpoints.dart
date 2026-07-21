/// REST endpoint paths, relative to [AppConfig.baseUrl].
///
/// V1 ships against local mock data sources (see [AppConfig.useMockData]),
/// but every repository is already wired to a [remote] data source that
/// targets these paths, so switching a feature to a live backend later is a
/// one-line change in that feature's binding — never a UI change.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';
  static const String bagList = '/bags';
  static const String skipBag = '/bags/skip';
  static const String designImages = '/reports/design-images';
  static const String qcChecking = '/reports/qc-checking';
  static const String timingReport = '/reports/timing';
  static const String artistProduction = '/reports/artist-production';
  static const String folloperReport = '/reports/folloper';
}
