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

  /// QC Checking's centrally-selected "Diamond QC Checker" — the same
  /// person applies to every employee/bag under the currently selected
  /// department until changed; see `QcPendingDashboardController`.
  static const String selectedDiaQcChecker = 'selected_dia_qc_checker';
}
