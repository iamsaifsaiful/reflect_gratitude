import '../logic/dates.dart';
import 'prompt.dart';

/// One day's journal entry. Every section is optional plain text.
class Entry {
  Entry({
    required DateTime date,
    this.reflection = '',
    this.gratitude = '',
    this.successes = '',
    this.finalThoughts = '',
    this.updatedAt,
  }) : date = dayOnly(date);

  final DateTime date;
  final String reflection;
  final String gratitude;
  final String successes;
  final String finalThoughts;
  final DateTime? updatedAt;

  String get key => dateKey(date);

  String textFor(PromptKind kind) => switch (kind) {
        PromptKind.reflection => reflection,
        PromptKind.gratitude => gratitude,
        PromptKind.successes => successes,
        PromptKind.finalThoughts => finalThoughts,
      };

  bool isAnswered(PromptKind kind) => textFor(kind).trim().isNotEmpty;

  /// How many of the four sections have any text (0-4).
  int get answeredCount => PromptKind.values.where(isAnswered).length;

  /// A day counts toward streaks once at least one section is written.
  bool get hasContent => answeredCount > 0;

  bool get isComplete => answeredCount == PromptKind.values.length;

  /// First written section, used as a preview in lists.
  String get preview {
    for (final kind in PromptKind.values) {
      final text = textFor(kind).trim();
      if (text.isNotEmpty) return text.replaceAll(RegExp(r'\s+'), ' ');
    }
    return '';
  }

  /// Individual gratitude items, one per line (commas also split a single line).
  List<String> get gratitudeItems {
    final lines = gratitude
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final items = lines.length == 1 ? lines.first.split(',') : lines;
    return items
        .map((item) => item.trim().replaceFirst(RegExp(r'^(\d+[.)]|[-•*])\s*'), ''))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Entry copyWithText(PromptKind kind, String value) => Entry(
        date: date,
        reflection: kind == PromptKind.reflection ? value : reflection,
        gratitude: kind == PromptKind.gratitude ? value : gratitude,
        successes: kind == PromptKind.successes ? value : successes,
        finalThoughts: kind == PromptKind.finalThoughts ? value : finalThoughts,
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'date': key,
        'reflection': reflection,
        'gratitude': gratitude,
        'successes': successes,
        'finalThoughts': finalThoughts,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  factory Entry.fromJson(Map<String, dynamic> json) {
    final updated = json['updatedAt'];
    return Entry(
      date: parseDateKey(json['date'] as String),
      reflection: (json['reflection'] as String?) ?? '',
      gratitude: (json['gratitude'] as String?) ?? '',
      successes: (json['successes'] as String?) ?? '',
      finalThoughts: (json['finalThoughts'] as String?) ?? '',
      updatedAt: updated is String ? DateTime.tryParse(updated) : null,
    );
  }
}

int wordCount(String text) =>
    text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
