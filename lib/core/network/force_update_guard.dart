import 'dart:convert';

import 'package:get/get.dart';

import '../config/app_version.dart';
import '../widgets/update_card.dart';

/// Single choke point every API response passes through (see
/// [ApiClient._send]) to check for the backend's force-update signal —
/// `{"status": "False", "message": ..., "minAppVersion": ..., "updateUrl":
/// ...}` — before the calling data source ever sees the response.
///
/// When the installed version is behind `minAppVersion`, [intercept]
/// returns `true` and the caller must never resolve that in-flight
/// request — a non-dismissible [UpdateCard] takes over instead of
/// whatever that specific call would normally have done with a `"False"`
/// status (an error snackbar, or a silent `(success: false, ...)`
/// outcome). Every other response — `status: true`, or `status: false`
/// without a newer `minAppVersion` — passes through completely
/// unaffected, so none of the app's existing per-endpoint status/message
/// handling changes.
class ForceUpdateGuard {
  const ForceUpdateGuard._();

  static bool _isShowing = false;

  static bool intercept(dynamic rawBody) {
    final Map<String, dynamic>? body = _asMap(rawBody);
    if (body == null) return false;

    final dynamic rawStatus = body['status'];
    final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
    if (status) return false;

    final String? minAppVersion = body['minAppVersion'] as String?;
    final String? updateUrl = body['updateUrl'] as String?;
    if (minAppVersion == null || updateUrl == null) return false;
    if (!AppVersion.isNewerThanInstalled(minAppVersion)) return false;

    _show(
      message: body['message'] as String? ?? '',
      minAppVersion: minAppVersion,
      updateUrl: updateUrl,
    );
    return true;
  }

  static Map<String, dynamic>? _asMap(dynamic rawBody) {
    if (rawBody is Map<String, dynamic>) return rawBody;
    if (rawBody is String) {
      try {
        final dynamic decoded = jsonDecode(rawBody);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        // Not JSON (e.g. a plain-text response) — no update signal possible.
      }
    }
    return null;
  }

  static void _show({required String message, required String minAppVersion, required String updateUrl}) {
    if (_isShowing) return;
    _isShowing = true;

    Get.dialog<void>(
      UpdateCard(message: message, minAppVersion: minAppVersion, updateUrl: updateUrl),
      barrierDismissible: false,
    ).then((_) => _isShowing = false);
  }
}
