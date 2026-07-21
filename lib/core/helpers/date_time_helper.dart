import 'package:intl/intl.dart';

/// Centralized date/time formatting so every screen renders dates
/// identically (e.g. the drawer's punch-in date/time, report filters).
class DateTimeHelper {
  const DateTimeHelper._();

  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');

  static String formatDate(DateTime value) => _date.format(value);

  static String formatMonthYear(DateTime value) => _monthYear.format(value);

  static String formatTime(DateTime value) => _time.format(value);

  static String formatDateTime(DateTime value) => _dateTime.format(value);

  static String formatDuration(Duration value) {
    final int hours = value.inHours;
    final int minutes = value.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  /// `HH:MM:SS` with unbounded (non-wrapping) hours — used for productivity
  /// stopwatches that can run well past 99 hours.
  static String formatStopwatch(Duration value) {
    final int hours = value.inHours;
    final int minutes = value.inMinutes.remainder(60);
    final int seconds = value.inSeconds.remainder(60);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(hours)}:${two(minutes)}:${two(seconds)}';
  }
}
