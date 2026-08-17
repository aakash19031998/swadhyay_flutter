/// REST endpoint paths, relative to [AppConfig.baseUrl].
///
/// V1 ships against local mock data sources (see [AppConfig.useMockData]),
/// but every repository is already wired to a [remote] data source that
/// targets these paths, so switching a feature to a live backend later is a
/// one-line change in that feature's binding — never a UI change.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String checkLogInNew = '/CheckLogInNew';
  static const String menuListNew = '/MenuListNew';
  static const String logout = '/Logout';
  static const String changePassword = '/ChangePasswordNew';
  static const String issuedBagListNew = '/IssuedBagListNew';
  static const String bagDetailsNew = '/BagDetailsNew';
  static const String imageAndVideoUrls = '/ImageAndVideoUrls';
  static const String pauseReasonMaster = '/PauseReasonMaster';
  static const String bagTimeTracking = '/BagTimeTracking';
  static const String bagDoneDetail = '/BagDoneDetail';
  static const String subWorkType = '/SubWorkType';
  static const String dummyAddBtnValidation = '/DummyAddBtnValidation';
  static const String bagDoneWithFirstReceive = '/BagDoneWithFirstReceive';
  static const String skipBag = '/bags/skip';
  static const String designMaster = '/DesignMaster';
  static const String qcChecking = '/reports/qc-checking';
  static const String timingReport = '/ArtistTimeUtilizationReport';
  static const String artistProduction = '/ArtistProductionRpt';
  static const String folloperReport = '/reports/folloper';
}
