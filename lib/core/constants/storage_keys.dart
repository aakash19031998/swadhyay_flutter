/// Keys used with [SecureStorageService] and [LocalStorageService].
///
/// Kept as one enum-like registry so a typo in a key string can never
/// silently create a second, orphaned storage entry.
class StorageKeys {
  const StorageKeys._();

  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String loggedInEmployee = 'logged_in_employee';
  static const String isLoggedIn = 'is_logged_in';
}
