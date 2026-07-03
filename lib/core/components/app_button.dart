import 'package:flutter/material.dart';
import '../config/app_radius.dart';
import '../config/app_spacing.dart';
import '../config/app_typography.dart';

enum AppButtonVariant { filled, outlined, text }

/// Tombol dengan built-in loading state — jangan ganti dengan spinner terpisah.
///
/// ```dart
/// AppButton(
///   label: 'Masuk',
///   isLoading: state is AuthLoading,
///   onPressed: _submit,
/// )
/// ```
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final AppButtonVariant variant;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.width,
    this.height = 52,
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 44,
  }) : variant = AppButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: variant == AppButtonVariant.filled
                    ? cs.onPrimary
                    : cs.primary,
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(label),
              ],
            ),
    );

    Widget button;
    final shape =
        RoundedRectangleBorder(borderRadius: AppRadius.lgAll);

    switch (variant) {
      case AppButtonVariant.filled:
        button = FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(width ?? double.infinity, height),
            shape: shape,
            textStyle: AppTypography.textTheme.labelLarge,
          ),
          child: child,
        );
      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(width ?? double.infinity, height),
            shape: shape,
            side: BorderSide(color: cs.primary, width: 1.5),
            textStyle: AppTypography.textTheme.labelLarge,
          ),
          child: child,
        );
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(width ?? 0, height),
            textStyle: AppTypography.textTheme.labelLarge,
          ),
          child: child,
        );
    }

    if (width != null) return SizedBox(width: width, child: button);
    return button;
  }
}
