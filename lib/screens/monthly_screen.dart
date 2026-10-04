import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/content.dart';
import '../logic/dates.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/abstract_art.dart';
import '../widgets/common.dart';
import 'entry_screen.dart';

/// Calendar tab: the month's theme, artwork, essay link and your days.
class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  /// First day of the month on screen. Null means "the current month".
  DateTime? _month;

  void _shift(DateTime month, int delta, DateTime current) {
    final next = DateTime(month.year, month.month + delta, 1);
    setState(() => _month = (next.year == current.year && next.month == current.month) ? null : next);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final today = state.today;
    final current = startOfMonth(today);
    final month = _month ?? current;
    final isCurrent = month.year == current.year && month.month == current.month;
    final theme = state.content.themeFor(month.month);
    final topInset = MediaQuery.paddingOf(context).top;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 300 + topInset,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AbstractArt(palette: theme.palette),
              const DecoratedBox(decoration: BoxDecoration(color: Color(0x1F3A2114))),
              Positioned(
                top: topInset + 12,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    SquareIconButton(
                      icon: Icons.chevron_left_rounded,
                      tooltip: 'Previous month',
                      size: 40,
                      background: AppColors.onAccent.withValues(alpha: 0.18),
                      foreground: AppColors.onAccent,
                      bordered: false,
                      onPressed: () => _shift(month, -1, current),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.onAccent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${monthShort[month.month - 1]} ${month.year}',
                        style: AppText.body(13, weight: FontWeight.w700, color: AppColors.onAccent),
                      ),
                    ),
                    const Spacer(),
                    SquareIconButton(
                      icon: Icons.chevron_right_rounded,
                      tooltip: 'Next month',
                      size: 40,
                      background: AppColors.onAccent.withValues(alpha: 0.18),
                      foreground: AppColors.onAccent,
                      bordered: false,
                      onPressed: () => _shift(month, 1, current),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Eyebrow(
                      '${theme.monthName} · Month ${month.month.toString().padLeft(2, '0')}',
                      color: AppColors.onAccent.withValues(alpha: 0.9),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      theme.name,
                      style: AppText.display(44, weight: FontWeight.w600, color: AppColors.onAccent, height: 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Eyebrow("This month's intention"),
              const SizedBox(height: 8),
              Text(
                theme.intention,
                style: AppText.display(18, weight: FontWeight.w400, color: AppColors.inkSoft, height: 1.5),
              ),
              const SizedBox(height: 18),
              _EssayCard(theme: theme),
              if (isCurrent) ...[
                const SizedBox(height: 16),
                QuoteCard(quote: state.content.quoteFor(today), label: 'Quote of the day'),
              ],
              const SizedBox(height: 16),
              SoftCard(
                child: _MonthCalendar(
                  month: month,
                  today: today,
                  state: state,
                  onOpen: (day) => openEntry(context, day),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EssayCard extends StatelessWidget {
  const _EssayCard({required this.theme});

  final MonthTheme theme;

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(theme.blogUrl);
    var opened = false;
    if (uri != null && theme.blogUrl.isNotEmpty) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened) {
      messenger.showSnackBar(const SnackBar(content: Text("Couldn't open the essay. Check your connection and try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.surfaceWarm,
      borderColor: AppColors.lineWarm,
      padding: const EdgeInsets.all(16),
      onTap: () => _open(context),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.menu_book_outlined, size: 22, color: AppColors.onAccent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(theme.essayTitle, style: AppText.display(16, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${theme.monthName} essay · ${theme.readMinutes} min read',
                  style: AppText.body(12, color: const Color(0xFFA99C8C)),
                ),
              ],
            ),
          ),
          const Icon(Icons.north_east_rounded, size: 20, color: AppColors.terracotta),
        ],
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({required this.month, required this.today, required this.state, required this.onOpen});

  final DateTime month;
  final DateTime today;
  final AppState state;
  final ValueChanged<DateTime> onOpen;

  @override
  Widget build(BuildContext context) {
    final days = daysInMonth(month.year, month.month);
    final offset = DateTime(month.year, month.month, 1).weekday - 1; // weeks start on Monday
    var written = 0;
    for (var d = 1; d <= days; d++) {
      if (state.isWritten(DateTime(month.year, month.month, d))) written++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Your ${monthNames[month.month - 1]}', style: AppText.display(17, weight: FontWeight.w600)),
            ),
            Text(
              '$written ${written == 1 ? 'entry' : 'entries'}',
              style: AppText.body(12, weight: FontWeight.w700, color: AppColors.sage),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final letter in weekdayLetter)
              Expanded(
                child: Center(
                  child: Text(letter, style: AppText.body(10, weight: FontWeight.w800, color: const Color(0xFFC0B3A2))),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          children: [
            for (var i = 0; i < offset; i++) const SizedBox.shrink(),
            for (var d = 1; d <= days; d++)
              _CalendarDay(
                day: DateTime(month.year, month.month, d),
                today: today,
                written: state.isWritten(DateTime(month.year, month.month, d)),
                onOpen: onOpen,
              ),
          ],
        ),
      ],
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({required this.day, required this.today, required this.written, required this.onOpen});

  final DateTime day;
  final DateTime today;
  final bool written;
  final ValueChanged<DateTime> onOpen;

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(day, today);
    final isFuture = daysBetween(today, day) > 0;
    final Color fill = written
        ? AppColors.terracotta
        : isFuture
            ? AppColors.background
            : AppColors.empty;
    final Color textColor = written
        ? AppColors.onAccent
        : isFuture
            ? const Color(0xFFCBBEAD)
            : AppColors.faint;

    return Semantics(
      button: !isFuture,
      label: '${monthNames[day.month - 1]} ${day.day}${written ? ', written' : ''}${isToday ? ', today' : ''}',
      excludeSemantics: true,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: isToday ? const BorderSide(color: AppColors.sage, width: 2) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isFuture ? null : () => onOpen(day),
          child: Center(
            child: Text(
              '${day.day}',
              style: AppText.body(12, weight: isToday ? FontWeight.w800 : FontWeight.w700, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
