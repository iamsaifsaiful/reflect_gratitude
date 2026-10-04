import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../logic/dates.dart';
import '../logic/streaks.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/abstract_art.dart';
import '../widgets/common.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final stats = state.stats;
    final today = state.today;
    final weekStart = startOfWeek(today);
    final weekCounts = [for (var i = 0; i < 7; i++) state.answeredOn(addDays(weekStart, i))];
    final weekWritten = weekCounts.where((count) => count > 0).length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
        children: [
          const Eyebrow('Your journey'),
          const SizedBox(height: 2),
          Text('Progress', style: AppText.display(26)),
          const SizedBox(height: 16),
          _StreakHero(stats: stats),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _StatTile(value: '${stats.totalEntries}', label: 'Total entries', color: AppColors.terracotta)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(value: '${stats.entriesThisMonth}', label: 'This month', color: AppColors.sage)),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '${(stats.consistency * 100).round()}%',
                  label: 'Consistency',
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('This week', style: AppText.display(17, weight: FontWeight.w600))),
                    Text('$weekWritten of 7 days', style: AppText.body(12, weight: FontWeight.w700, color: AppColors.sage)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 124,
                  child: _WeekBars(counts: weekCounts, todayIndex: today.weekday - 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(child: _MonthGrid(state: state, today: today)),
          const SizedBox(height: 14),
          Text(
            'A week counts when you write on ${StreakRules.weeklyGoal} days, and a month on ${StreakRules.monthlyGoal}.',
            textAlign: TextAlign.center,
            style: AppText.body(12, color: AppColors.subtle),
          ),
        ],
      ),
    );
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    final longest = stats.longestDailyStreak;
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(color: Color(0x5E784A2A), blurRadius: 26, offset: Offset(0, 12), spreadRadius: -16),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            const Positioned.fill(child: AbstractArt(palette: AppColors.emberPalette)),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: AppColors.onAccent.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department_outlined, size: 38, color: AppColors.onAccent),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${stats.dailyStreak}',
                              style: AppText.display(46, weight: FontWeight.w600, color: AppColors.onAccent, height: 1),
                            ),
                            const SizedBox(width: 8),
                            Text('day streak', style: AppText.body(15, weight: FontWeight.w700, color: AppColors.onAccent)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Longest streak · $longest ${longest == 1 ? 'day' : 'days'}',
                          style: AppText.body(13, color: AppColors.onAccent.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppText.display(24, weight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(11, weight: FontWeight.w700, color: AppColors.subtle),
          ),
        ],
      ),
    );
  }
}

/// Seven bars, Monday to Sunday. Height is how many of the four prompts were written.
class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.counts, required this.todayIndex});

  final List<int> counts;
  final int todayIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < counts.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        widthFactor: 1,
                        heightFactor: math.max(counts[i] / 4, 0.06),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: counts[i] == 0
                                ? const Color(0xFFEFE0D2)
                                : Color.lerp(const Color(0xFFEBD3C2), AppColors.terracotta, counts[i] / 4),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weekdayLetter[i],
                    style: AppText.body(
                      11,
                      weight: i == todayIndex ? FontWeight.w800 : FontWeight.w700,
                      color: i == todayIndex ? AppColors.terracotta : const Color(0xFFA99C8C),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// One square per day of the current month.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.state, required this.today});

  final AppState state;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final days = daysInMonth(today.year, today.month);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${monthNames[today.month - 1]} consistency', style: AppText.display(17, weight: FontWeight.w600)),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: 7,
          crossAxisSpacing: 7,
          children: [
            for (var d = 1; d <= days; d++) _cell(DateTime(today.year, today.month, d)),
          ],
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _Legend(color: AppColors.empty, label: 'Missed'),
            _Legend(color: AppColors.partial, label: 'Partial'),
            _Legend(color: AppColors.terracotta, label: 'All four'),
          ],
        ),
      ],
    );
  }

  Widget _cell(DateTime day) {
    final isToday = isSameDay(day, today);
    final isFuture = daysBetween(today, day) > 0;
    final answered = state.answeredOn(day);
    final Color fill;
    if (isFuture) {
      fill = Colors.transparent;
    } else if (answered == 0) {
      fill = AppColors.empty;
    } else if (answered < 4) {
      fill = AppColors.partial;
    } else {
      fill = AppColors.terracotta;
    }
    return Semantics(
      label: '${monthShort[day.month - 1]} ${day.day}: '
          '${isFuture ? 'still ahead' : answered == 0 ? 'not written' : '$answered of 4 prompts'}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: AppColors.ink, width: 1.5)
              : isFuture
                  ? Border.all(color: AppColors.line)
                  : null,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppText.body(11, weight: FontWeight.w700, color: const Color(0xFFA99C8C))),
      ],
    );
  }
}
