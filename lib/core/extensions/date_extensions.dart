import '../utils/app_date_utils.dart';

extension DateTimeX on DateTime {
  bool get isToday      => AppDateUtils.isToday(this);
  bool get isThisMonth  => AppDateUtils.isThisMonth(this);
  String get short      => AppDateUtils.formatShort(this);
  String get full       => AppDateUtils.formatFull(this);
  String get monthYear  => AppDateUtils.formatMonthYear(this);
  String get dayMonth   => AppDateUtils.formatDayMonth(this);
  String get weekday3   => AppDateUtils.formatWeekday(this);
  String get relative   => AppDateUtils.relativeLabel(this);
  DateTime get dayStart => AppDateUtils.startOfDay(this);
  DateTime get dayEnd   => AppDateUtils.endOfDay(this);
}
