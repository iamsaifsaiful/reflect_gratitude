import 'package:flutter/material.dart';

import '../logic/dates.dart';
import '../logic/streaks.dart';
import '../models/entry.dart';
import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'entry_screen.dart';

/// Journal tab: one week at a time.
class WeeklyScreen extends StatefulWidget {
  const WeeklyScreen({super.key});

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  /// Monday of the week on screen. Null means "the current week", so the
  /// screen moves on by itself when a new week starts.
  DateTime? _weekStart;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final today = state.today;
    final currentWeek = startOfWeek(today);
    final weekStart = _weekStart ?? currentWeek;
    final isCurrent = isSameDay(weekStart, currentWeek);
    final weekEnd = addDays(weekStart, 6);
    final entries = state.entriesBetween(weekStart, weekEnd);
    final written = entries.length;
    final goalMet = written >= StreakRules.weeklyGoal;

    // Gratitude notes from the week, oldest first, without repeats.
    final seen = <String>{};
    final gratitude = <String>[];
    for (final entry in entries.reversed) {
      for (final item in entry.gratitudeItems) {
        final short = item.length > 40 ? '${item.substring(0, 39)}…' : item;
        if (seen.add(short.toLowerCase())) gratitude.add(short);
      }
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(isCurrent ? 'Week in review' : 'Past week'),
                    const SizedBox(height: 4),
                    Text(formatWeekRange(weekStart), style: AppText.display(25)),
                  ],
                ),
              ),
              SquareIconButton(
                icon: Icons.chevron_left_rounded,
                tooltip: 'Previous week',
                size: 40,
                onPressed: () => setState(() => _weekStart = addDays(weekStart, -7)),
              ),
              const SizedBox(width: 8),
              SquareIconButton(
                icon: Icons.chevron_right_rounded,
                tooltip: 'Next week',
                size: 40,
                onPressed: isCurrent
                    ? null
                    : () => setState(() {
                          final next = addDays(weekStart, 7);
                          _weekStart = isSameDay(next, currentWeek) ? null : next;
                        }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < 7; i++)
                      _DayCircle(
                        day: addDays(weekStart, i),
                        today: today,
                        written: state.isWritten(addDays(weekStart, i)),
                        onTap: (day) => openEntry(context, day),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF0E5D6)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      goalMet ? Icons.local_fire_department_outlined : Icons.flag_outlined,
                      size: 18,
                      color: AppColors.sage,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goalMet ? 'Weekly goal reached' : 'Goal: ${StreakRules.weeklyGoal} days this week',
                        style: AppText.body(14, weight: FontWeight.w700, color: AppColors.body),
                      ),
                    ),
                    Text('$written/7', style: AppText.display(19, weight: FontWeight.w600, color: AppColors.terracotta)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _GratitudeCard(items: gratitude),
          const SizedBox(height: 20),
          Text(
            isCurrent ? 'Entries this week' : 'Entries that week',
            style: AppText.display(17, weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            Text(
              'No entries yet. Tap a day above to write one.',
              style: AppText.body(14, weight: FontWeight.w400, color: AppColors.muted),
            )
          else
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: EntryRow(entry: entry, onTap: () => openEntry(context, entry.date)),
              ),
        ],
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({required this.day, required this.today, required this.written, required this.onTap});

  final DateTime day;
  final DateTime today;
  final bool written;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(day, today);
    final isFuture = daysBetween(today, day) > 0;
    final label = weekdayShort[day.weekday - 1];

    final BoxDecoration decoration;
    if (written) {
      decoration = const BoxDecoration(color: AppColors.terracotta, shape: BoxShape.circle);
    } else if (isToday) {
      decoration = BoxDecoration(
        color: const Color(0xFFEFE0D2),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD8C3AE), width: 1.5),
      );
    } else {
      decoration = BoxDecoration(
        color: isFuture ? const Color(0xFFF7F0E6) : const Color(0xFFEFE0D2),
        shape: BoxShape.circle,
      );
    }

    return Semantics(
      button: !isFuture,
      label: '${weekdayNames[day.weekday - 1]} ${day.day}, ${written ? 'written' : 'not written'}',
      excludeSemantics: true,
      child: InkResponse(
        onTap: isFuture ? null : () => onTap(day),
        radius: 26,
        child: Column(
          children: [
            Text(
              label,
              style: AppText.body(11, weight: FontWeight.w700, color: written || isToday ? AppColors.subtle : const Color(0xFFC0B3A2)),
            ),
            const SizedBox(height: 7),
            Container(
              width: 34,
              height: 34,
              decoration: decoration,
              child: written ? const Icon(Icons.check_rounded, size: 17, color: AppColors.onAccent) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _GratitudeCard extends StatelessWidget {
  const _GratitudeCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9EAD9), Color(0xFFDFE2CC)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6DAC0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 18, color: Color(0xFF6B7A54)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This week you were grateful for',
                  style: AppText.display(17, weight: FontWeight.w600, color: const Color(0xFF3F4A2E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'Your gratitude notes from this week will gather here.',
              style: AppText.body(13.5, weight: FontWeight.w400, color: AppColors.sageDark),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in items.take(12))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF7EC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD9DCC6)),
                    ),
                    child: Text(
                      item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(13, weight: FontWeight.w700, color: AppColors.sageDark),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// A day's entry in a list: date, a two-line preview, and one dot per prompt.
class EntryRow extends StatelessWidget {
  const EntryRow({super.key, required this.entry, required this.onTap});

  final Entry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Text(
                  weekdayShort[entry.date.weekday - 1].toUpperCase(),
                  style: AppText.body(11, weight: FontWeight.w800, color: AppColors.eyebrow),
                ),
                Text('${entry.date.day}', style: AppText.display(20, weight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(width: 1, height: 44, color: const Color(0xFFF0E5D6)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(13.5, weight: FontWeight.w400, color: AppColors.body, height: 1.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final prompt in prompts)
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Dot(
                          size: 7,
                          color: entry.isAnswered(prompt.kind) ? prompt.color : AppColors.track,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
