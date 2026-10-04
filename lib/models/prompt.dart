import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The four guided sections of a daily entry.
enum PromptKind { reflection, gratitude, successes, finalThoughts }

class PromptInfo {
  const PromptInfo({
    required this.kind,
    required this.title,
    required this.question,
    required this.summary,
    required this.hint,
    required this.color,
    required this.softColor,
    required this.icon,
  });

  final PromptKind kind;
  final String title;

  /// The guiding question shown above the text field.
  final String question;

  /// One-line description used on collapsed rows.
  final String summary;

  /// Placeholder text inside the empty field.
  final String hint;

  final Color color;
  final Color softColor;
  final IconData icon;

  int get index => kind.index;

  static PromptInfo of(PromptKind kind) => prompts[kind.index];
}

const List<PromptInfo> prompts = [
  PromptInfo(
    kind: PromptKind.reflection,
    title: 'Reflection',
    question: 'What moment from today do you want to sit with a little longer?',
    summary: 'A moment worth sitting with',
    hint: 'Write freely. A few lines is plenty.',
    color: AppColors.terracotta,
    softColor: AppColors.terracottaSoft,
    icon: Icons.wb_sunny_outlined,
  ),
  PromptInfo(
    kind: PromptKind.gratitude,
    title: 'Gratitude',
    question: 'What are three things you\'re thankful for today?',
    summary: 'Three things you\'re thankful for',
    hint: 'One per line, small things count.',
    color: AppColors.gold,
    softColor: AppColors.goldSoft,
    icon: Icons.favorite_border_rounded,
  ),
  PromptInfo(
    kind: PromptKind.successes,
    title: 'Successes',
    question: 'What went well today, big or small?',
    summary: 'Wins worth celebrating, big or small',
    hint: 'Finished something? Showed up anyway? Note it here.',
    color: AppColors.sage,
    softColor: AppColors.sageSoft,
    icon: Icons.emoji_events_outlined,
  ),
  PromptInfo(
    kind: PromptKind.finalThoughts,
    title: 'Final thoughts',
    question: 'What would you like to carry into tomorrow?',
    summary: 'Anything to carry into tomorrow',
    hint: 'An intention, a reminder, or a closing thought.',
    color: AppColors.plum,
    softColor: AppColors.plumSoft,
    icon: Icons.chat_bubble_outline_rounded,
  ),
];
