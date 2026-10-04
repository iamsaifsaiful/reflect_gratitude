import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';
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
        builder: (context, child) => PhoneWidthOnWideScreens(child: child ?? const SizedBox.shrink()),
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

/// On tablets and in desktop browsers (the web preview), keeps the phone
/// layout in a centred column instead of stretching it across the screen.
/// Phones are unaffected.
class PhoneWidthOnWideScreens extends StatelessWidget {
  const PhoneWidthOnWideScreens({super.key, required this.child});

  final Widget child;

  static const double breakpoint = 600;
  static const double phoneWidth = 440;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= breakpoint) return child;
    return ColoredBox(
      color: const Color(0xFFE9DECF),
      child: Center(
        child: Container(
          width: phoneWidth,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.background,
            boxShadow: [BoxShadow(color: Color(0x26784A2A), blurRadius: 40, spreadRadius: -10)],
          ),
          clipBehavior: Clip.hardEdge,
          child: MediaQuery(
            data: media.copyWith(size: Size(phoneWidth, media.size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}
