import 'package:flutter/material.dart';
import '../../../../core/components/global_shimmer.dart';
import '../../../../core/config/app_spacing.dart';

/// Daftar skeleton ulasan standalone.
class ReviewListSkeleton extends StatelessWidget {
  final int itemCount;
  const ReviewListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => const ReviewCardShimmer(),
      );
}
