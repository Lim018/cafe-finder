import 'package:flutter/material.dart';
import '../../../../core/components/global_shimmer.dart';
import '../../../../core/config/app_spacing.dart';

/// Skeleton untuk PlacesListTab: search + chip row + 5 PlaceCard.
class PlacesListSkeleton extends StatelessWidget {
  const PlacesListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.md),
            child: Row(children: [
              Expanded(
                child: GlobalShimmer(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GlobalShimmer(
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ]),
          ),
          // Promo banner skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.sm),
            child: GlobalShimmer(
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          // Chips skeleton
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              children: [72.0, 100.0, 86.0, 94.0, 78.0].map((w) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GlobalShimmer(
                  child: Container(
                    width: w, height: 36,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(999)),
                  ),
                ),
              )).toList(),
            ),
          ),
          // Cards skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
            child: Column(
              children: List.generate(5, (_) => const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                child: PlaceCardShimmer(),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
