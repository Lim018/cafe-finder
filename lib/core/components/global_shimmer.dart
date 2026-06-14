import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GlobalShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const GlobalShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use theme colors for light/dark mode adaptation by default
    return Shimmer.fromColors(
      baseColor: baseColor ?? theme.colorScheme.surfaceContainerHighest,
      highlightColor: highlightColor ?? theme.colorScheme.surface,
      child: child,
    );
  }
}

class ShimmerAvatar extends StatelessWidget {
  final double radius;

  const ShimmerAvatar({super.key, this.radius = 24.0});

  @override
  Widget build(BuildContext context) {
    return GlobalShimmer(
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 100.0,
    this.width,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return GlobalShimmer(
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;

  const ShimmerList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerAvatar(radius: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerCard(height: 16, width: double.infinity),
                const SizedBox(height: 8),
                const ShimmerCard(height: 16, width: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
