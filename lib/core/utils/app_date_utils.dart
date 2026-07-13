import 'package:intl/intl.dart';

/// Date formatting and manipulation helpers.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _fullDate   = DateFormat('EEEE, d MMMM yyyy');
  static final DateFormat _shortDate  = DateFormat('d MMM yyyy');
  static final DateFormat _monthYear  = DateFormat('MMMM yyyy');
  static final DateFormat _dayMonth   = DateFormat('d MMM');
  static final DateFormat _weekday    = DateFormat('EEE');
  static final DateFormat _time       = DateFormat('HH:mm');
  static final DateFormat _yearMonth  = DateFormat('MMM yy');
  static final DateFormat _iso        = DateFormat('yyyy-MM-dd');

  static String formatFull(DateTime dt)     => _fullDate.format(dt);
  static String formatShort(DateTime dt)    => _shortDate.format(dt);
  static String formatMonthYear(DateTime dt)=> _monthYear.format(dt);
  static String formatDayMonth(DateTime dt) => _dayMonth.format(dt);
  static String formatWeekday(DateTime dt)  => _weekday.format(dt);
  static String formatTime(DateTime dt)     => _time.format(dt);
  static String formatYearMonth(DateTime dt)=> _yearMonth.format(dt);
  static String formatIso(DateTime dt)      => _iso.format(dt);

  /// Returns true if [dt] falls within the current calendar month.
  static bool isThisMonth(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month;
  }

  /// Returns true if [dt] is today.
  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  /// Start-of-day for [dt].
  static DateTime startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// End-of-day for [dt].
  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

  /// First day of the month containing [dt].
  static DateTime startOfMonth(DateTime dt) => DateTime(dt.year, dt.month);

  /// Last day of the month containing [dt].
  static DateTime endOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month + 1, 0, 23, 59, 59);

  /// List of the last [months] months (newest first).
  static List<DateTime> lastNMonths(int months) {
    final now = DateTime.now();
    return List.generate(
      months,
      (i) => DateTime(now.year, now.month - i),
    );
  }

  /// Friendly relative label: 'Today', 'Yesterday', or the short date.
  static String relativeLabel(DateTime dt) {
    if (isToday(dt)) return 'Today';
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday';
    }
    return formatShort(dt);
  }
}
