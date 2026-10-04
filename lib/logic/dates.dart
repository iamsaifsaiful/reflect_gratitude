/// Small, dependency-free date helpers.
///
/// All "day" values in the app are local dates at midnight. Arithmetic goes
/// through the DateTime(year, month, day + n) constructor so daylight-saving
/// changes never shift a day.
library;

const List<String> monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const List<String> monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Index 0 is Monday, matching DateTime.weekday - 1.
const List<String> weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

const List<String> weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const List<String> weekdayLetter = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _two(int n) => n.toString().padLeft(2, '0');

/// Stable storage key for a day, e.g. "2026-09-09".
String dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

DateTime parseDateKey(String key) {
  final parts = key.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

/// Whole days from [a] to [b], ignoring time of day and daylight saving.
int daysBetween(DateTime a, DateTime b) {
  final ua = DateTime.utc(a.year, a.month, a.day);
  final ub = DateTime.utc(b.year, b.month, b.day);
  return ub.difference(ua).inDays;
}

/// Monday of the week that contains [d].
DateTime startOfWeek(DateTime d) => addDays(dayOnly(d), -(d.weekday - 1));

DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

int daysInYear(int year) => daysBetween(DateTime(year, 1, 1), DateTime(year + 1, 1, 1));

/// 1-based day of the year (1 January is day 1).
int dayOfYear(DateTime d) => daysBetween(DateTime(d.year, 1, 1), d) + 1;

/// "Wednesday, Sep 9"
String formatLongDate(DateTime d) => '${weekdayNames[d.weekday - 1]}, ${monthShort[d.month - 1]} ${d.day}';

/// "Wed · Sep 9"
String formatShortDate(DateTime d) => '${weekdayShort[d.weekday - 1]} · ${monthShort[d.month - 1]} ${d.day}';

/// "Sep 7 – 13" or "Sep 28 – Oct 4"
String formatWeekRange(DateTime weekStart) {
  final end = addDays(weekStart, 6);
  final startText = '${monthShort[weekStart.month - 1]} ${weekStart.day}';
  if (end.month == weekStart.month) return '$startText – ${end.day}';
  return '$startText – ${monthShort[end.month - 1]} ${end.day}';
}

String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
