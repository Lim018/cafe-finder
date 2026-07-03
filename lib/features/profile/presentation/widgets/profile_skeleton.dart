import 'package:flutter/material.dart';
import '../../../../core/components/global_shimmer.dart';
import '../../../../core/config/app_spacing.dart';

/// Skeleton untuk ProfileTab.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(children: [
        GlobalShimmer(
          child: Container(height: 230, color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(children: [
            const SizedBox(height: AppSpacing.xl),
            const ShimmerAvatar(radius: 52),
            const SizedBox(height: AppSpacing.lg),
            const Center(child: ShimmerLine(width: 140, height: 18)),
            const SizedBox(height: AppSpacing.sm),
            const Center(child: ShimmerLine(width: 180, height: 13)),
            const SizedBox(height: AppSpacing.md),
            const Center(child: ShimmerLine(width: 80, height: 26)),
            const SizedBox(height: AppSpacing.xl),
            Row(children: List.generate(3, (_) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: GlobalShimmer(
                  child: Container(height: 72,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18))),
                ),
              ),
            ))),
            const SizedBox(height: AppSpacing.lg),
            GlobalShimmer(
              child: Container(height: 180,
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(20))),
            ),
          ]),
        ),
      ]),
    );
  }
}
