import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The standard cream card with a hairline border.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 20,
    this.color = AppColors.surface,
    this.borderColor = AppColors.line,
    this.shadow = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final bool shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow
            ? const [BoxShadow(color: Color(0x33784A2A), blurRadius: 22, offset: Offset(0, 10), spreadRadius: -14)]
            : null,
      ),
      child: Material(
        color: color,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: color == null ? AppText.eyebrow : AppText.eyebrow.copyWith(color: color),
    );
  }
}

/// Full-width terracotta button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.track,
          disabledForegroundColor: AppColors.subtle,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: AppText.body(15.5, weight: FontWeight.w800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[Icon(leadingIcon, size: 18), const SizedBox(width: 8)],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            if (trailingIcon != null) ...[const SizedBox(width: 8), Icon(trailingIcon, size: 18)],
          ],
        ),
      ),
    );
  }
}

/// Rounded-square icon button used in top bars (back, close, arrows).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 44,
    this.background = AppColors.surface,
    this.foreground = AppColors.muted,
    this.bordered = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final Color background;
  final Color foreground;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size * 0.3),
          side: bordered ? const BorderSide(color: AppColors.line) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: 20, color: enabled ? foreground : AppColors.track),
          ),
        ),
      ),
    );
  }
}

/// Small rounded square holding a prompt's icon.
class IconBox extends StatelessWidget {
  const IconBox({super.key, required this.icon, required this.color, required this.background, this.size = 34});

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size * 0.3)),
      child: Icon(icon, size: size * 0.52, color: color),
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

/// Today's quote on a warm card with a large opening quote mark.
class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key, required this.quote, this.label = "Today's quote"});

  final String quote;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lineWarm),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 14,
            child: Text('“', style: AppText.display(56, color: AppColors.quoteMark, height: 1)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote,
                  style: AppText.display(17, weight: FontWeight.w400, style: FontStyle.italic, color: AppColors.inkSoft, height: 1.45),
                ),
                const SizedBox(height: 10),
                Text('— ${label.toUpperCase()}', style: AppText.body(12, weight: FontWeight.w700, color: AppColors.eyebrow, letterSpacing: 0.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
