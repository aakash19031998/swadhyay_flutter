/// Extracts numeric values exactly as they appear in raw JSON response text.
///
/// `dart:convert`'s JSON decoder parses `1.4000` into the `double` `1.4`,
/// permanently discarding the original trailing zeros — there is no way to
/// recover them from the decoded value afterwards. Screens that must show a
/// number exactly as the backend sent it (e.g. Bag Detail's Diamond
/// Details/Bag RM Summary tables) instead pull the literal digit text
/// straight out of the raw response body via [extract], before it's ever
/// run through `jsonDecode`.
class RawJsonNumbers {
  const RawJsonNumbers._();

  /// Every raw numeric literal following `"key":` in [rawJson], in the
  /// order they appear — callers zip this positionally against the
  /// already-decoded list the same key came from, so [key] must not repeat
  /// under some other, unrelated object in the same payload.
  static List<String> extract(String rawJson, String key) {
    final RegExp pattern = RegExp('"$key"\\s*:\\s*(-?\\d+(?:\\.\\d+)?)');
    return [for (final match in pattern.allMatches(rawJson)) match.group(1)!];
  }
}
