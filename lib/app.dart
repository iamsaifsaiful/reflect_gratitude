import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class ReflectApp extends StatelessWidget {
  const ReflectApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Reflect & Gratitude',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const RootGate(),
      ),
    );
  }
}

/// Shows the welcome screen until the user has told us their name.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: state.needsWelcome
          ? const WelcomeScreen(key: ValueKey('welcome'))
          : const HomeShell(key: ValueKey('home')),
    );
  }
}
