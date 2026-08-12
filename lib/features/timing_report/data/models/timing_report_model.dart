import '../../domain/entities/timing_report_entity.dart';

class TimingReportModel extends TimingReportEntity {
  const TimingReportModel({
    required super.date,
    required super.usedMinutes,
    required super.unusedMinutes,
    required super.punchedMinutes,
  });

  /// Parses one `ArtistTimeUtilizationReport` `data` array item.
  /// Field-name casing given for this endpoint's contract has been wrong
  /// twice already (camelCase, then PascalCase — neither matched what the
  /// live server actually sends), so keys are looked up case-insensitively
  /// here instead of assuming one exact casing a third time. `UsedMinutes`/
  /// `UnusedMinutes` are genuinely fractional (e.g. `180.53`), kept as
  /// `double` all the way through to the chart/summary widgets rather than
  /// rounded away here.
  factory TimingReportModel.fromJson(Map<String, dynamic> json) {
    return TimingReportModel(
      date: DateTime.tryParse(_field(json, 'WorkDate')?.toString() ?? '') ?? DateTime.now(),
      usedMinutes: (_field(json, 'UsedMinutes') as num?)?.toDouble() ?? 0,
      unusedMinutes: (_field(json, 'UnusedMinutes') as num?)?.toDouble() ?? 0,
      punchedMinutes: (_field(json, 'PunchedMinutes') as num?)?.toDouble() ?? 0,
    );
  }

  /// Case-insensitive lookup — tries [name] as given first (cheap, exact
  /// match in the common case), then falls back to scanning [json]'s keys
  /// for a case-insensitive match.
  static dynamic _field(Map<String, dynamic> json, String name) {
    if (json.containsKey(name)) return json[name];
    final String needle = name.toLowerCase();
    for (final entry in json.entries) {
      if (entry.key.toLowerCase() == needle) return entry.value;
    }
    return null;
  }
}
