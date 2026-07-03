import 'package:flutter/material.dart';
import '../../../../core/components/global_shimmer.dart';
import '../../../../core/config/app_spacing.dart';

/// Skeleton untuk MapTab saat MapStatus.loading.
class MapSkeleton extends StatelessWidget {
  const MapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(children: [
      GlobalShimmer(
        child: Container(
            color: Colors.white, width: double.infinity, height: double.infinity),
      ),
      Positioned(
        top: 100,
        right: AppSpacing.lg,
        child: Column(children: [
          GlobalShimmer(child: Container(width: 46, height: 46,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14)))),
          const SizedBox(height: AppSpacing.sm),
          GlobalShimmer(child: Container(width: 46, height: 88,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14)))),
        ]),
      ),
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: cs.primary, strokeWidth: 2.5),
            const SizedBox(height: AppSpacing.md),
            Text('Memuat peta…',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
          ]),
        ),
      ),
    ]);
  }
}
