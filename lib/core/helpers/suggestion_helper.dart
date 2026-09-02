/// Distinct field values across [items] whose text contains [text]
/// (case-insensitive) — used by every "load once, filter locally" list
/// screen to back its search field's autocomplete suggestions (Bag List,
/// QC Bag List). Checked per item, one [fieldSelectors] entry at a time (not
/// all of one field across every item first), so results interleave in the
/// same order the original hand-written loops did. Capped at [limit].
List<String> suggestionsFor<T>(
  String text,
  List<T> items,
  List<String Function(T item)> fieldSelectors, {
  int limit = 8,
}) {
  final String needle = text.trim().toLowerCase();
  if (needle.isEmpty) return const [];

  final List<String> matches = [];
  for (final T item in items) {
    for (final String Function(T item) selector in fieldSelectors) {
      final String value = selector(item);
      if (value.toLowerCase().contains(needle) && !matches.contains(value)) {
        matches.add(value);
      }
    }
  }
  return matches.take(limit).toList(growable: false);
}
