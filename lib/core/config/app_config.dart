/// Environment-level configuration.
///
/// [useMockData] is the single switch that decides whether feature
/// repositories are bound to their in-memory mock data source or their real
/// [ApiClient]-backed remote data source. Flipping it to `false` once a
/// backend exists requires no change to any controller, use case or view —
/// only to the relevant feature [Binding].
class AppConfig {
  const AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.88.137:99/api',
  );

  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );

  /// Separate from [useMockData]: the navigation drawer is wired to the live
  /// `MenuListNew` backend by default, independent of other still-mocked
  /// features.
  static const bool useMockDrawerMenu = bool.fromEnvironment(
    'USE_MOCK_DRAWER_MENU',
    defaultValue: false,
  );

  /// Separate from [useMockData]: Bag List is wired to the live
  /// `IssuedBagListNew` backend by default, independent of other
  /// still-mocked features.
  static const bool useMockBagList = bool.fromEnvironment(
    'USE_MOCK_BAG_LIST',
    defaultValue: false,
  );

  /// Separate from [useMockData]: the Bag List thumbnail's image/video
  /// gallery is wired to the live `ImageAndVideoUrls` backend by default,
  /// independent of other still-mocked features.
  static const bool useMockBagMediaGallery = bool.fromEnvironment(
    'USE_MOCK_BAG_MEDIA_GALLERY',
    defaultValue: false,
  );

  static const Duration connectTimeout = Duration(minutes: 2);
  static const Duration receiveTimeout = Duration(minutes: 2);

  /// Simulated latency for mock data sources so loading states are visible
  /// and representative of real network conditions during development.
  static const Duration mockLatency = Duration(milliseconds: 600);
}
