import 'package:package_info_plus/package_info_plus.dart';

/// The app's real installed version — read once from the platform (which in
/// turn comes from `pubspec.yaml`'s `version: <versionName>+<buildNumber>`,
/// embedded at build time) instead of the hardcoded, per-endpoint
/// `appVersion` literals every data source used to send.
///
/// [init] must be awaited before [buildNumber]/[versionName] are read —
/// done once in `main()`, the same as [LocalStorageService.init].
class AppVersion {
  const AppVersion._();

  static late final String buildNumber;
  static late final String versionName;

  static Future<void> init() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    buildNumber = info.buildNumber;
    versionName = info.version;
  }

  /// True when [remoteVersion] (e.g. a backend's `minAppVersion`) is newer
  /// than the version installed on this device — compared numerically
  /// segment-by-segment (`"0.1.10"` > `"0.1.9"`), not as plain strings,
  /// and tolerant of a different number of segments on either side.
  static bool isNewerThanInstalled(String remoteVersion) {
    final List<int> remote = _segments(remoteVersion);
    final List<int> installed = _segments(versionName);

    for (int i = 0; i < remote.length || i < installed.length; i++) {
      final int r = i < remote.length ? remote[i] : 0;
      final int l = i < installed.length ? installed[i] : 0;
      if (r != l) return r > l;
    }
    return false;
  }

  static List<int> _segments(String version) {
    return version.split('.').map((part) => int.tryParse(part.trim()) ?? 0).toList();
  }
}
