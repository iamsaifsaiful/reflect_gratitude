import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/abstract_art.dart';
import '../widgets/common.dart';

/// First launch: a short welcome and the user's name for greetings.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _start() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    AppScope.read(context).setName(name);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.read(context);
    final palette = state.content.themeFor(state.today.month).palette;
    final canStart = _name.text.trim().isNotEmpty;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.line),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkStatusBar,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: SizedBox(
                    height: 260,
                    child: AbstractArt(
                      palette: palette,
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Eyebrow(
                                "Let's spend the year together",
                                color: AppColors.onAccent.withValues(alpha: 0.9),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Reflect &\nGratitude',
                                style: AppText.display(36, weight: FontWeight.w600, color: AppColors.onAccent, height: 1.05),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text('A few quiet minutes a day', style: AppText.display(26)),
                const SizedBox(height: 10),
                Text(
                  'Reflect on your day, note what you\'re grateful for, and celebrate your wins. '
                  'Each month brings a new theme to guide you.',
                  style: AppText.body(15, weight: FontWeight.w400, color: AppColors.body, height: 1.55),
                ),
                const SizedBox(height: 26),
                Text('What should we call you?', style: AppText.body(13, weight: FontWeight.w700, color: AppColors.muted)),
                const SizedBox(height: 8),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _start(),
                  style: AppText.body(16),
                  decoration: InputDecoration(
                    hintText: 'Your first name',
                    hintStyle: AppText.body(16, weight: FontWeight.w400, color: AppColors.faint),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Begin',
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: canStart ? _start : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your entries stay on this phone.',
                  textAlign: TextAlign.center,
                  style: AppText.body(12, color: AppColors.subtle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
