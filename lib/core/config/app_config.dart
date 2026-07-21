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
    defaultValue: 'https://api.swadhyay.example.com',
  );

  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Simulated latency for mock data sources so loading states are visible
  /// and representative of real network conditions during development.
  static const Duration mockLatency = Duration(milliseconds: 600);
}
