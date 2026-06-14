import 'package:flutter/material.dart';

class GlobalEmptyState extends StatelessWidget {
  final Widget? illustration;
  final String title;
  final String subtitle;
  final String? ctaText;
  final VoidCallback? onCtaPressed;

  const GlobalEmptyState({
    super.key,
    this.illustration,
    required this.title,
    required this.subtitle,
    this.ctaText,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(height: 32),
            ] else ...[
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (ctaText != null && onCtaPressed != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onCtaPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(ctaText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
