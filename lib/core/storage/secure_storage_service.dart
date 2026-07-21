import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Wraps [FlutterSecureStorage] for the small set of sensitive values
/// (tokens) that must never live in plain-text `get_storage`.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveAuthToken(String token) => _storage.write(key: StorageKeys.authToken, value: token);

  Future<String?> readAuthToken() => _storage.read(key: StorageKeys.authToken);

  Future<void> saveRefreshToken(String token) => _storage.write(key: StorageKeys.refreshToken, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: StorageKeys.refreshToken);

  Future<void> clear() => _storage.deleteAll();
}
