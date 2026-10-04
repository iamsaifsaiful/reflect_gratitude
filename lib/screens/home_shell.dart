import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'monthly_screen.dart';
import 'progress_screen.dart';
import 'today_screen.dart';
import 'weekly_screen.dart';

/// The four tabs: Today, Journal (weekly review), Progress, Calendar (monthly theme).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static const int todayTab = 0;
  static const int journalTab = 1;
  static const int progressTab = 2;
  static const int calendarTab = 3;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = HomeShell.todayTab;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    // The Calendar tab opens on artwork, so it needs light status-bar icons.
    final SystemUiOverlayStyle overlay = _index == HomeShell.calendarTab ? lightStatusBar : darkStatusBar;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            TodayScreen(onOpenMonth: () => _select(HomeShell.calendarTab)),
            const WeeklyScreen(),
            const ProgressScreen(),
            const MonthlyScreen(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(index: _index, onSelect: _select),
      ),
    );
  }
}
