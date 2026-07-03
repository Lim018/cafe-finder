import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_spacing.dart';

// ─── Base ──────────────────────────────────────────────────────────────────

class GlobalShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const GlobalShimmer({super.key, required this.child, this.baseColor, this.highlightColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: baseColor ?? (isDark ? const Color(0xFF2A241E) : const Color(0xFFECE4DC)),
      highlightColor: highlightColor ?? (isDark ? const Color(0xFF352E27) : const Color(0xFFF4EEE8)),
      child: child,
    );
  }
}

// ─── Primitives ────────────────────────────────────────────────────────────

class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerCard({super.key, this.height = 100, this.width, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) => GlobalShimmer(
        child: Container(
          height: height,
          width: width ?? double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(borderRadius)),
        ),
      );
}

class ShimmerAvatar extends StatelessWidget {
  final double radius;
  const ShimmerAvatar({super.key, this.radius = 24});

  @override
  Widget build(BuildContext context) =>
      GlobalShimmer(child: CircleAvatar(radius: radius, backgroundColor: Colors.white));
}

class ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerLine({super.key, this.width, this.height = 14, this.borderRadius = 7});

  @override
  Widget build(BuildContext context) => GlobalShimmer(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(borderRadius)),
        ),
      );
}

// ─── Composites ────────────────────────────────────────────────────────────

/// Skeleton satu PlaceCard (foto + 2 baris teks).
class PlaceCardShimmer extends StatelessWidget {
  const PlaceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) => GlobalShimmer(
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 158,
              decoration: const BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(height: 16, width: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: AppSpacing.sm),
                Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
              ]),
            ),
          ]),
        ),
      );
}

/// Skeleton kartu favorit horizontal.
class FavoriteCardShimmer extends StatelessWidget {
  const FavoriteCardShimmer({super.key});

  @override
  Widget build(BuildContext context) => GlobalShimmer(
        child: Container(
          height: 108,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            Container(
              width: 84,
              decoration: const BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.horizontal(left: Radius.circular(20))),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(height: 14, width: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
                const SizedBox(height: AppSpacing.sm),
                Container(height: 11, width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
              ]),
            ),
          ]),
        ),
      );
}

/// Skeleton satu kartu ulasan.
class ReviewCardShimmer extends StatelessWidget {
  const ReviewCardShimmer({super.key});

  @override
  Widget build(BuildContext context) => GlobalShimmer(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CircleAvatar(radius: 20, backgroundColor: Colors.white),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(height: 13, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: AppSpacing.xs),
                Container(height: 10, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
                const SizedBox(height: AppSpacing.sm),
                Container(height: 11, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
              ]),
            ),
          ]),
        ),
      );
}

/// ShimmerList generik.
class ShimmerList extends StatelessWidget {
  final int itemCount;
  const ShimmerList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (_, __) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const ShimmerAvatar(radius: 24),
          const SizedBox(width: AppSpacing.md),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ShimmerLine(height: 14),
            SizedBox(height: AppSpacing.sm),
            ShimmerLine(width: 150, height: 12),
          ])),
        ]),
      );
}
