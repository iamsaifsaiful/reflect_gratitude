import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reflect_gratitude/app.dart';
import 'package:reflect_gratitude/data/content.dart';
import 'package:reflect_gratitude/data/entry_store.dart';
import 'package:reflect_gratitude/state/app_state.dart';

ContentRepository testContent() => ContentRepository(
      themes: [
        for (var m = 1; m <= 12; m++)
          MonthTheme(
            month: m,
            name: 'Theme $m',
            intention: 'Intention $m',
            essayTitle: 'Essay $m',
            blogUrl: '',
            readMinutes: 3,
            palette: const [Color(0xFFE7B27A), Color(0xFFC87E52), Color(0xFF9E4E33)],
          ),
      ],
      quotes: const ['A test quote.'],
    );

Future<AppState> makeState({String? name}) async {
  final state = AppState(
    store: MemoryEntryStore(name: name),
    content: testContent(),
    clock: () => DateTime(2026, 9, 9, 8),
  );
  await state.load();
  return state;
}

/// A phone-width screen tall enough to show each page without scrolling.
void useTallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 4200);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('first launch asks for a name, then shows Today', (tester) async {
    useTallPhone(tester);
    final state = await makeState();
    await tester.pumpWidget(ReflectApp(state: state));
    await tester.pumpAndSettle();

    expect(find.text('What should we call you?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Saif');
    await tester.pump();
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning,\nSaif'), findsOneWidget);
    expect(find.text('Theme 9'), findsWidgets);
    expect(find.text('0 of 4'), findsOneWidget);
  });

  testWidgets('writing a section saves it and updates Today', (tester) async {
    useTallPhone(tester);
    final state = await makeState(name: 'Saif');
    await tester.pumpWidget(ReflectApp(state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Begin today's entry"));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 4'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'A slow walk before work.');
    await tester.pump();
    await tester.tap(find.text('Continue to Gratitude'));
    await tester.pumpAndSettle();

    expect(state.entryFor(DateTime(2026, 9, 9)).reflection, 'A slow walk before work.');
    expect(find.text('Step 2 of 4'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('1 of 4'), findsOneWidget);
    expect(state.stats.dailyStreak, 1);
  });

  testWidgets('tabs switch between screens', (tester) async {
    useTallPhone(tester);
    final state = await makeState(name: 'Saif');
    await tester.pumpWidget(ReflectApp(state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();
    expect(find.text('Sep 7 – 13'), findsOneWidget);

    await tester.tap(find.text('Progress').last);
    await tester.pumpAndSettle();
    expect(find.text('day streak'), findsOneWidget);

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('Intention 9'), findsOneWidget);
  });
}
