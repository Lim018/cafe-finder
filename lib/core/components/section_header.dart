import 'package:flutter/material.dart';
import '../config/app_spacing.dart';
import '../config/app_typography.dart';

/// Header section reusable — judul + optional trailing action.
///
/// ```dart
/// SectionHeader(
///   title: 'Ulasan',
///   trailing: TextButton(onPressed: _onAdd, child: const Text('Tulis')),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.sm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
