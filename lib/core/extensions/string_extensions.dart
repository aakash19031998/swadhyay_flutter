/// Small, pure string helpers shared across features.
extension StringExtensions on String {
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String get initials {
    final List<String> parts = trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
}
