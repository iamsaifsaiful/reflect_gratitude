import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

Future<void> showEditNameDialog(BuildContext context) async {
  final state = AppScope.read(context);
  final result = await showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(initial: state.name),
  );
  if (result != null && result.trim().isNotEmpty) {
    await state.setName(result);
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text('Your name', style: AppText.display(20, weight: FontWeight.w600)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => Navigator.of(context).pop(value),
        style: AppText.body(16),
        decoration: const InputDecoration(hintText: 'What should we call you?'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: AppText.body(14, weight: FontWeight.w700, color: AppColors.muted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text('Save', style: AppText.body(14, weight: FontWeight.w800, color: AppColors.terracotta)),
        ),
      ],
    );
  }
}
