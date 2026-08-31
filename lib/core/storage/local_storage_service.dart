import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import '../constants/storage_keys.dart';

/// Wraps [GetStorage] for small, non-sensitive persisted values (flags,
/// cached JSON blobs). Anything sensitive belongs in [SecureStorageService]
/// instead.
class LocalStorageService {
  LocalStorageService(this._box);

  final GetStorage _box;

  static Future<void> init() => GetStorage.init();

  bool get isLoggedIn => _box.read<bool>(StorageKeys.isLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) => _box.write(StorageKeys.isLoggedIn, value);

  Future<void> saveJson(String key, Map<String, dynamic> value) => _box.write(key, jsonEncode(value));

  Map<String, dynamic>? readJson(String key) {
    final String? raw = _box.read<String>(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();

  /// `{qcCode, qcName}` of the centrally-selected "Diamond QC Checker" —
  /// `null` until one is picked on the QC Checking screen (see
  /// `QcPendingDashboardController`), or after it's cleared on a department switch
  /// or on leaving the QC Checking screen.
  Map<String, dynamic>? get selectedDiaQcChecker => readJson(StorageKeys.selectedDiaQcChecker);

  Future<void> saveSelectedDiaQcChecker(Map<String, dynamic> value) =>
      saveJson(StorageKeys.selectedDiaQcChecker, value);

  Future<void> clearSelectedDiaQcChecker() => remove(StorageKeys.selectedDiaQcChecker);
}
