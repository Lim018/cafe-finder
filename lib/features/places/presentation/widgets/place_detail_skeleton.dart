import 'package:flutter/material.dart';
import '../../../../core/components/global_shimmer.dart';
import '../../../../core/config/app_spacing.dart';

/// Skeleton untuk PlaceDetailScreen — trigger dari PlaceDetailLoading.
class PlaceDetailSkeleton extends StatelessWidget {
  const PlaceDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: GlobalShimmer(
            child: Container(height: 300, color: Colors.white),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
                color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  ShimmerLine(width: 180, height: 22),
                  SizedBox(height: AppSpacing.sm),
                  ShimmerLine(width: 130, height: 13),
                ])),
                const SizedBox(width: AppSpacing.lg),
                GlobalShimmer(child: Container(width: 64, height: 52,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
              ]),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                Expanded(child: GlobalShimmer(child: Container(height: 46,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))))),
                const SizedBox(width: AppSpacing.sm),
                ...List.generate(3, (_) => Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: GlobalShimmer(child: Container(width: 46, height: 46,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
                )),
              ]),
              const SizedBox(height: AppSpacing.xl),
              const ShimmerLine(height: 14),
              const SizedBox(height: AppSpacing.sm),
              const ShimmerLine(width: 300, height: 12),
              const SizedBox(height: AppSpacing.sm),
              const ShimmerLine(width: 260, height: 12),
              const SizedBox(height: AppSpacing.xl),
              Row(children: const [
                ShimmerLine(width: 90, height: 32),
                SizedBox(width: AppSpacing.sm),
                ShimmerLine(width: 110, height: 32),
                SizedBox(width: AppSpacing.sm),
                ShimmerLine(width: 80, height: 32),
              ]),
              const SizedBox(height: AppSpacing.xl),
              const ShimmerLine(width: 90, height: 16),
              const SizedBox(height: AppSpacing.md),
              const ReviewCardShimmer(),
              const SizedBox(height: AppSpacing.md),
              const ReviewCardShimmer(),
            ]),
          ),
        ),
      ],
    );
  }
}
