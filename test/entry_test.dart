import 'package:flutter_test/flutter_test.dart';
import 'package:reflect_gratitude/models/entry.dart';
import 'package:reflect_gratitude/models/prompt.dart';

void main() {
  final day = DateTime(2026, 9, 9);

  test('counts answered sections', () {
    final empty = Entry(date: day);
    expect(empty.answeredCount, 0);
    expect(empty.hasContent, isFalse);

    final partial = Entry(date: day, reflection: 'A slow walk.', gratitude: '   ');
    expect(partial.answeredCount, 1);
    expect(partial.hasContent, isTrue);
    expect(partial.isAnswered(PromptKind.gratitude), isFalse);

    final full = Entry(date: day, reflection: 'a', gratitude: 'b', successes: 'c', finalThoughts: 'd');
    expect(full.isComplete, isTrue);
  });

  test('keeps only the date part', () {
    final entry = Entry(date: DateTime(2026, 9, 9, 22, 15));
    expect(entry.date, day);
    expect(entry.key, '2026-09-09');
  });

  test('round-trips through JSON', () {
    final entry = Entry(
      date: day,
      reflection: 'Reflection',
      gratitude: 'Rain\nCoffee',
      successes: 'Shipped it',
      finalThoughts: 'Rest early',
      updatedAt: DateTime(2026, 9, 9, 21),
    );
    final copy = Entry.fromJson(entry.toJson());
    expect(copy.key, entry.key);
    expect(copy.reflection, entry.reflection);
    expect(copy.gratitude, entry.gratitude);
    expect(copy.successes, entry.successes);
    expect(copy.finalThoughts, entry.finalThoughts);
    expect(copy.updatedAt, entry.updatedAt);
  });

  test('splits gratitude into items', () {
    final lines = Entry(date: day, gratitude: 'Slow mornings\n- A call with Mum\n2. Rain\n');
    expect(lines.gratitudeItems, ['Slow mornings', 'A call with Mum', 'Rain']);

    final oneLine = Entry(date: day, gratitude: 'coffee, rain, 3 good friends');
    expect(oneLine.gratitudeItems, ['coffee', 'rain', '3 good friends']);
  });

  test('word count', () {
    expect(wordCount(''), 0);
    expect(wordCount('  one  two\nthree '), 3);
  });
}
