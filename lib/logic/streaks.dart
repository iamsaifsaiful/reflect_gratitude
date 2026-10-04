import 'dates.dart';

/// Streak rules. Change these numbers to tune how forgiving the app is.
class StreakRules {
  StreakRules._();

  /// Days written in a Monday-to-Sunday week for it to count.
  static const int weeklyGoal = 4;

  /// Days written in a calendar month for it to count.
  static const int monthlyGoal = 20;
}

class ProgressStats {
  const ProgressStats({
    required this.dailyStreak,
    required this.longestDailyStreak,
    required this.weeklyStreak,
    required this.monthlyStreak,
    required this.totalEntries,
    required this.entriesThisMonth,
    required this.consistency,
  });

  final int dailyStreak;
  final int longestDailyStreak;
  final int weeklyStreak;
  final int monthlyStreak;
  final int totalEntries;
  final int entriesThisMonth;

  /// Share of days written since the first entry, from 0 to 1.
  final double consistency;

  static const empty = ProgressStats(
    dailyStreak: 0,
    longestDailyStreak: 0,
    weeklyStreak: 0,
    monthlyStreak: 0,
    totalEntries: 0,
    entriesThisMonth: 0,
    consistency: 0,
  );
}

/// [writtenDays] holds date keys (see [dateKey]) of days that count.
ProgressStats computeStats(Set<String> writtenDays, DateTime today) {
  if (writtenDays.isEmpty) return ProgressStats.empty;
  final day = dayOnly(today);
  final pastOrToday = writtenDays.where((key) => daysBetween(parseDateKey(key), day) >= 0).toSet();
  return ProgressStats(
    dailyStreak: dailyStreak(pastOrToday, day),
    longestDailyStreak: longestDailyStreak(pastOrToday),
    weeklyStreak: weeklyStreak(pastOrToday, day),
    monthlyStreak: monthlyStreak(pastOrToday, day),
    totalEntries: pastOrToday.length,
    entriesThisMonth: pastOrToday.where((key) {
      final d = parseDateKey(key);
      return d.year == day.year && d.month == day.month;
    }).length,
    consistency: consistency(pastOrToday, day),
  );
}

/// Consecutive written days ending today. If today isn't written yet the
/// streak is still alive and counts back from yesterday.
int dailyStreak(Set<String> days, DateTime today) {
  var cursor = dayOnly(today);
  if (!days.contains(dateKey(cursor))) cursor = addDays(cursor, -1);
  var count = 0;
  while (days.contains(dateKey(cursor))) {
    count++;
    cursor = addDays(cursor, -1);
  }
  return count;
}

int longestDailyStreak(Set<String> days) {
  if (days.isEmpty) return 0;
  final sorted = days.map(parseDateKey).toList()..sort();
  var longest = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    run = daysBetween(sorted[i - 1], sorted[i]) == 1 ? run + 1 : 1;
    if (run > longest) longest = run;
  }
  return longest;
}

int _countInRange(Set<String> days, DateTime start, int length) {
  var count = 0;
  for (var i = 0; i < length; i++) {
    if (days.contains(dateKey(addDays(start, i)))) count++;
  }
  return count;
}

/// Consecutive Monday-to-Sunday weeks that met [StreakRules.weeklyGoal].
/// The current week only adds to the streak once its goal is met; until then
/// it doesn't break it either.
int weeklyStreak(Set<String> days, DateTime today) {
  var week = startOfWeek(today);
  var streak = 0;
  if (_countInRange(days, week, 7) >= StreakRules.weeklyGoal) streak++;
  week = addDays(week, -7);
  while (_countInRange(days, week, 7) >= StreakRules.weeklyGoal) {
    streak++;
    week = addDays(week, -7);
  }
  return streak;
}

/// Consecutive calendar months that met [StreakRules.monthlyGoal], with the
/// same rule for the month in progress.
int monthlyStreak(Set<String> days, DateTime today) {
  int countMonth(DateTime first) => _countInRange(days, first, daysInMonth(first.year, first.month));

  var month = DateTime(today.year, today.month, 1);
  var streak = 0;
  if (countMonth(month) >= StreakRules.monthlyGoal) streak++;
  month = DateTime(month.year, month.month - 1, 1);
  while (countMonth(month) >= StreakRules.monthlyGoal) {
    streak++;
    month = DateTime(month.year, month.month - 1, 1);
  }
  return streak;
}

/// Days written divided by days elapsed since the first entry (inclusive).
double consistency(Set<String> days, DateTime today) {
  if (days.isEmpty) return 0;
  final first = days.map(parseDateKey).reduce((a, b) => a.isBefore(b) ? a : b);
  final span = daysBetween(first, today) + 1;
  if (span <= 0) return 0;
  return (days.length / span).clamp(0.0, 1.0).toDouble();
}
