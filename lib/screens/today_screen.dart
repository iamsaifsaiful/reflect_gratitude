import 'package:flutter/material.dart';

import '../data/content.dart';
import '../logic/dates.dart';
import '../models/entry.dart';
import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/abstract_art.dart';
import '../widgets/common.dart';
import '../widgets/name_dialog.dart';
import 'entry_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.onOpenMonth});

  /// Switches to the Calendar tab.
  final VoidCallback onOpenMonth;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final today = state.today;
    final stats = state.stats;
    final theme = state.content.themeFor(today.month);
    final entry = state.entryFor(today);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
        children: [
          _Header(today: today, greeting: greetingFor(state.now), name: state.name),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StreakTile(
                  value: stats.dailyStreak,
                  label: 'Daily',
                  icon: Icons.local_fire_department_outlined,
                  color: AppColors.terracotta,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreakTile(
                  value: stats.weeklyStreak,
                  label: 'Weekly',
                  icon: Icons.check_rounded,
                  color: AppColors.sage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreakTile(
                  value: stats.monthlyStreak,
                  label: 'Monthly',
                  icon: Icons.star_outline_rounded,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MonthHeroCard(theme: theme, onTap: onOpenMonth),
          const SizedBox(height: 20),
          QuoteCard(quote: state.content.quoteFor(today)),
          const SizedBox(height: 20),
          _TodayEntryCard(
            entry: entry,
            onOpen: (kind) => openEntry(context, today, initialPrompt: kind),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.today, required this.greeting, required this.name});

  final DateTime today;
  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(formatShortDate(today)),
              const SizedBox(height: 6),
              Text('$greeting,\n$name', style: AppText.display(27)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: 'Change your name',
          child: Material(
            color: const Color(0xFFE7E1D0),
            shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => showEditNameDialog(context),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Text(initial, style: AppText.display(18, weight: FontWeight.w600, color: AppColors.sage)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StreakTile extends StatelessWidget {
  const StreakTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label streak: $value',
      excludeSemantics: true,
      child: SoftCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: color),
                const SizedBox(width: 5),
                Text('$value', style: AppText.body(20, weight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: AppText.body(11, weight: FontWeight.w700, color: AppColors.subtle, letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }
}

/// The month's theme over its artwork. Used on Today.
class MonthHeroCard extends StatelessWidget {
  const MonthHeroCard({super.key, required this.theme, required this.onTap});

  final MonthTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Semantics(
      button: true,
      label: '${theme.monthName} theme: ${theme.name}. Open the month.',
      excludeSemantics: true,
      child: Container(
        height: 158,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(color: Color(0x73784A2A), blurRadius: 24, offset: Offset(0, 10), spreadRadius: -14),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AbstractArt(palette: theme.palette),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Eyebrow(
                            '${theme.monthName} · Theme',
                            color: AppColors.onAccent.withValues(alpha: 0.85),
                          ),
                        ),
                        _GlassPill(text: 'Month ${theme.month} of 12'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          theme.name,
                          style: AppText.display(30, weight: FontWeight.w600, color: AppColors.onAccent, height: 1),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.link_rounded, size: 16, color: AppColors.onAccent),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Read this month's reflection",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.body(13, weight: FontWeight.w700, color: AppColors.onAccent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.onAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: AppText.body(11, weight: FontWeight.w700, color: AppColors.onAccent)),
    );
  }
}

class _TodayEntryCard extends StatelessWidget {
  const _TodayEntryCard({required this.entry, required this.onOpen});

  final Entry entry;

  /// Opens the entry, at a specific prompt or (null) wherever the user left off.
  final void Function(PromptKind? kind) onOpen;

  @override
  Widget build(BuildContext context) {
    final answered = entry.answeredCount;
    final label = switch (answered) {
      0 => "Begin today's entry",
      4 => "Review today's entry",
      _ => "Continue today's entry",
    };
    return SoftCard(
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text("Today's reflection", style: AppText.display(18, weight: FontWeight.w600)),
              ),
              Text('$answered of 4', style: AppText.body(12, weight: FontWeight.w700, color: AppColors.sage)),
            ],
          ),
          const SizedBox(height: 8),
          for (final prompt in prompts)
            _PromptLine(
              prompt: prompt,
              done: entry.isAnswered(prompt.kind),
              onTap: () => onOpen(prompt.kind),
            ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: label,
            leadingIcon: Icons.edit_outlined,
            onPressed: () => onOpen(null),
          ),
        ],
      ),
    );
  }
}

class _PromptLine extends StatelessWidget {
  const _PromptLine({required this.prompt, required this.done, required this.onTap});

  final PromptInfo prompt;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Dot(color: prompt.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                prompt.title,
                style: AppText.body(14, color: done ? AppColors.ink : AppColors.body),
              ),
            ),
            done
                ? const Icon(Icons.check_circle_rounded, size: 19, color: AppColors.sage)
                : const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.faint),
          ],
        ),
      ),
    );
  }
}
