import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/dates.dart';
import '../models/entry.dart';
import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Opens the guided entry for [day]. Pass [initialPrompt] to jump to one section.
Future<void> openEntry(BuildContext context, DateTime day, {PromptKind? initialPrompt}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => EntryScreen(date: dayOnly(day), initialPrompt: initialPrompt),
    ),
  );
}

/// The four-step daily entry. Text saves automatically as you type.
class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key, required this.date, this.initialPrompt});

  final DateTime date;
  final PromptKind? initialPrompt;

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final Map<PromptKind, TextEditingController> _controllers = {};
  final Map<PromptKind, FocusNode> _focusNodes = {};
  late AppState _state;
  Timer? _debounce;
  int _step = 0;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _state = AppScope.read(context);
    final entry = _state.entryFor(widget.date);
    for (final kind in PromptKind.values) {
      final controller = TextEditingController(text: entry.textFor(kind));
      controller.addListener(_onTextChanged);
      _controllers[kind] = controller;
      _focusNodes[kind] = FocusNode();
    }
    final firstOpen = PromptKind.values.firstWhere(
      (kind) => !entry.isAnswered(kind),
      orElse: () => PromptKind.reflection,
    );
    _step = (widget.initialPrompt ?? firstOpen).index;
    _ready = true;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // word count and step bar
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _save);
  }

  String _text(PromptKind kind) => _controllers[kind]!.text;

  Entry _currentEntry() => Entry(
        date: widget.date,
        reflection: _text(PromptKind.reflection),
        gratitude: _text(PromptKind.gratitude),
        successes: _text(PromptKind.successes),
        finalThoughts: _text(PromptKind.finalThoughts),
        updatedAt: DateTime.now(),
      );

  Future<void> _save() {
    _debounce?.cancel();
    _debounce = null;
    return _state.saveEntry(_currentEntry());
  }

  void _goTo(int step) {
    _save();
    setState(() => _step = step);
    final node = _focusNodes[PromptKind.values[step]]!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) node.requestFocus();
    });
  }

  Future<void> _finish() async {
    await _save();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final wroteSomething = _currentEntry().hasContent;
    Navigator.of(context).pop();
    if (wroteSomething) {
      messenger.showSnackBar(const SnackBar(content: Text('Entry saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(widget.date, _state.today);
    final isLast = _step == prompts.length - 1;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _save();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: darkStatusBar,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SquareIconButton(
                            icon: Icons.chevron_left_rounded,
                            tooltip: 'Back',
                            size: 40,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Eyebrow(isToday ? 'Daily entry' : 'Past entry'),
                            const SizedBox(height: 2),
                            Text(
                              formatLongDate(widget.date),
                              style: AppText.display(17, weight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 64,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _finish,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.sage,
                              minimumSize: const Size(48, 44),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                            ),
                            child: Text('Save', style: AppText.body(14, weight: FontWeight.w800, color: AppColors.sage)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _StepBar(
                    current: _step,
                    answered: [for (final kind in PromptKind.values) _text(kind).trim().isNotEmpty],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    children: [
                      for (final prompt in prompts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: prompt.index == _step
                              ? _ActivePrompt(
                                  prompt: prompt,
                                  controller: _controllers[prompt.kind]!,
                                  focusNode: _focusNodes[prompt.kind]!,
                                )
                              : _CollapsedPrompt(
                                  prompt: prompt,
                                  text: _text(prompt.kind),
                                  onTap: () => _goTo(prompt.index),
                                ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: PrimaryButton(
                    label: isLast ? 'Finish entry' : 'Continue to ${prompts[_step + 1].title}',
                    trailingIcon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    onPressed: isLast ? _finish : () => _goTo(_step + 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.current, required this.answered});

  final int current;
  final List<bool> answered;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < answered.length; i++) {
      if (i > 0) children.add(const SizedBox(width: 6));
      final color = i == current
          ? AppColors.terracotta
          : answered[i]
              ? AppColors.terracotta.withValues(alpha: 0.4)
              : AppColors.track;
      children.add(
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 5,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
        ),
      );
    }
    return Semantics(
      label: 'Step ${current + 1} of ${answered.length}',
      excludeSemantics: true,
      child: Row(children: children),
    );
  }
}

class _ActivePrompt extends StatelessWidget {
  const _ActivePrompt({required this.prompt, required this.controller, required this.focusNode});

  final PromptInfo prompt;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final words = wordCount(controller.text);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.activeBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x40784A2A), blurRadius: 26, offset: Offset(0, 12), spreadRadius: -18),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBox(icon: prompt.icon, color: prompt.color, background: prompt.softColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prompt.title, style: AppText.display(19, weight: FontWeight.w600)),
                    Text(
                      'Step ${prompt.index + 1} of ${prompts.length}',
                      style: AppText.body(12, color: AppColors.subtle),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prompt.question,
            style: AppText.display(15, weight: FontWeight.w400, style: FontStyle.italic, color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEE2D1)),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 5,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: AppText.body(15, weight: FontWeight.w400, color: AppColors.inkSoft, height: 1.6),
              decoration: InputDecoration.collapsed(
                hintText: prompt.hint,
                hintStyle: AppText.body(15, weight: FontWeight.w400, color: AppColors.faint, height: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            words == 1 ? '1 word' : '$words words',
            style: AppText.body(12, color: AppColors.faint),
          ),
        ],
      ),
    );
  }
}

class _CollapsedPrompt extends StatelessWidget {
  const _CollapsedPrompt({required this.prompt, required this.text, required this.onTap});

  final PromptInfo prompt;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final answered = text.trim().isNotEmpty;
    return SoftCard(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      onTap: onTap,
      child: Row(
        children: [
          IconBox(icon: prompt.icon, color: prompt.color, background: prompt.softColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prompt.title, style: AppText.display(16, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  answered ? text.trim().replaceAll(RegExp(r'\s+'), ' ') : prompt.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(12.5, weight: FontWeight.w400, color: answered ? AppColors.body : const Color(0xFFA99C8C)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          answered
              ? const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.sage)
              : const Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFFC9BCA9)),
        ],
      ),
    );
  }
}
