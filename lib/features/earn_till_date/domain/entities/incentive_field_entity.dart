/// Highlights a row in the "Incentive Details (Ticked Fields)" table — a
/// visual call-out only, no effect on the value itself.
enum IncentiveFieldHighlight {
  none,

  /// e.g. "Diamond Broken" — a deduction worth flagging.
  warning,

  /// e.g. "Broken Diamond Qty" — worth noting but not a deduction itself.
  caution,

  /// e.g. "Earn Till Date" — a final/payable figure.
  success,

  /// e.g. "Total Point" — a notable running total, distinct from a
  /// deduction/caution/final-figure row.
  info,
}

/// One row of the incentive table: a metric/field name and its recorded
/// value, in the same order the physical incentive paper record lists them.
class IncentiveFieldEntity {
  const IncentiveFieldEntity({
    required this.srNo,
    required this.metricName,
    required this.recordedValue,
    this.highlight = IncentiveFieldHighlight.none,
    this.isBold = false,
    this.unit,
  });

  final int srNo;
  final String metricName;
  final String recordedValue;
  final IncentiveFieldHighlight highlight;
  final bool isBold;

  /// Trailing unit shown after the value, e.g. "pcs" for a piece count.
  final String? unit;
}
