import 'package:intl/intl.dart';

/// Centralized date/time formatting so every screen renders dates
/// identically (e.g. the drawer's punch-in date/time, report filters).
class DateTimeHelper {
  const DateTimeHelper._();

  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateDashed = DateFormat('dd-MM-yyyy');
  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');

  static String formatDate(DateTime value) => _date.format(value);

  /// `YYYY-MM-DD` — the request-body date format expected by report
  /// endpoints like `ArtistProductionRpt` (`frDt`/`toDt`).
  static String formatApiDate(DateTime value) => _apiDate.format(value);

  /// `DD-MM-YYYY` (dashed) — distinct from [formatDate]'s `dd/MM/yyyy`
  /// because some fields (currently Bag Detail's delivery date) are
  /// specced against this exact separator while every other date display
  /// in the app keeps the slashed format.
  static String formatDateDashed(DateTime value) => _dateDashed.format(value);

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
