import 'package:flutter_test/flutter_test.dart';
import 'package:reflect_gratitude/logic/dates.dart';
import 'package:reflect_gratitude/logic/streaks.dart';

/// Date keys for days [offsets] days before [today] (0 = today).
Set<String> daysBack(DateTime today, Iterable<int> offsets) =>
    {for (final offset in offsets) dateKey(addDays(today, -offset))};

/// Date keys for the first [count] days starting at [start].
Set<String> run(DateTime start, int count) =>
    {for (var i = 0; i < count; i++) dateKey(addDays(start, i))};

void main() {
  final wednesday = DateTime(2026, 9, 9); // week of Monday 7 September
  final sunday = DateTime(2026, 9, 13);

  group('dates', () {
    test('day of year', () {
      expect(dayOfYear(DateTime(2026, 1, 1)), 1);
      expect(dayOfYear(wednesday), 252);
    });

    test('weeks start on Monday', () {
      expect(startOfWeek(sunday), DateTime(2026, 9, 7));
      expect(startOfWeek(DateTime(2026, 9, 7)), DateTime(2026, 9, 7));
    });

    test('week range text', () {
      expect(formatWeekRange(DateTime(2026, 9, 7)), 'Sep 7 – 13');
      expect(formatWeekRange(DateTime(2026, 9, 28)), 'Sep 28 – Oct 4');
    });

    test('days in month', () {
      expect(daysInMonth(2026, 2), 28);
      expect(daysInMonth(2028, 2), 29);
      expect(daysInMonth(2026, 12), 31);
    });

    test('date keys round-trip', () {
      expect(dateKey(wednesday), '2026-09-09');
      expect(parseDateKey('2026-09-09'), wednesday);
    });
  });

  group('daily streak', () {
    test('counts consecutive days ending today', () {
      expect(dailyStreak(daysBack(wednesday, [0, 1, 2]), wednesday), 3);
    });

    test('stays alive while today is not written yet', () {
      expect(dailyStreak(daysBack(wednesday, [1, 2, 3, 4]), wednesday), 4);
    });

    test('a missed day breaks it', () {
      expect(dailyStreak(daysBack(wednesday, [0, 1, 3, 4]), wednesday), 2);
    });

    test('missing today and yesterday means no streak', () {
      expect(dailyStreak(daysBack(wednesday, [2, 3]), wednesday), 0);
    });

    test('runs across a month boundary', () {
      final day = DateTime(2026, 10, 2);
      expect(dailyStreak(daysBack(day, [0, 1, 2, 3]), day), 4);
    });

    test('longest streak', () {
      expect(longestDailyStreak(daysBack(wednesday, [0, 5, 6, 7, 8, 20, 21])), 4);
      expect(longestDailyStreak(<String>{}), 0);
    });
  });

  group('weekly streak', () {
    test('counts past weeks that met the goal', () {
      final days = {...run(DateTime(2026, 8, 31), 4), ...run(DateTime(2026, 8, 24), 4)};
      expect(weeklyStreak(days, wednesday), 2);
    });

    test('the current week adds once its goal is met', () {
      final days = {...run(DateTime(2026, 9, 7), 4), ...run(DateTime(2026, 8, 31), 4)};
      expect(weeklyStreak(days, sunday), 2);
    });

    test('a week below the goal breaks the streak', () {
      final days = {
        ...run(DateTime(2026, 9, 7), 4),
        ...run(DateTime(2026, 8, 31), StreakRules.weeklyGoal - 1),
        ...run(DateTime(2026, 8, 24), 4),
      };
      expect(weeklyStreak(days, sunday), 1);
    });
  });

  group('monthly streak', () {
    test('counts finished months that met the goal', () {
      final days = {
        ...run(DateTime(2026, 9, 1), 5),
        ...run(DateTime(2026, 8, 1), StreakRules.monthlyGoal),
        ...run(DateTime(2026, 7, 1), StreakRules.monthlyGoal),
        ...run(DateTime(2026, 6, 1), StreakRules.monthlyGoal - 1),
      };
      expect(monthlyStreak(days, wednesday), 2);
    });
  });

  group('computeStats', () {
    test('ignores future days and counts this month', () {
      final days = {
        ...daysBack(wednesday, [0, 1, 9]), // 9 Sep, 8 Sep, 31 Aug
        dateKey(DateTime(2026, 9, 20)), // future: ignored
      };
      final stats = computeStats(days, wednesday);
      expect(stats.totalEntries, 3);
      expect(stats.entriesThisMonth, 2);
      expect(stats.dailyStreak, 2);
      expect(stats.longestDailyStreak, 2);
      // 3 days written out of the 10 since the first entry (31 Aug to 9 Sep).
      expect(stats.consistency, closeTo(0.3, 1e-9));
    });

    test('no entries means zeros', () {
      final stats = computeStats(<String>{}, wednesday);
      expect(stats.totalEntries, 0);
      expect(stats.dailyStreak, 0);
      expect(stats.consistency, 0);
    });
  });
}
