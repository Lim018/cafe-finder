import 'package:flutter/material.dart';
import '../../../../core/components/global_shimmer.dart';
import '../../../../core/config/app_spacing.dart';

/// Skeleton untuk FavoritesTab — trigger dari FavoritesLoading.
class FavoritesSkeleton extends StatelessWidget {
  const FavoritesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => const FavoriteCardShimmer(),
    );
  }
}
