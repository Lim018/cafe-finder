import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_theme.dart';
import 'global_shimmer.dart';

/// Gambar kafe dengan Hero transition, shimmer placeholder, dan gradient overlay.
///
/// Tag hero otomatis: `cafe_image_${heroId}`.
/// Selalu sertakan heroId unik (biasanya place.id).
class CafeImage extends StatelessWidget {
  final String? imageUrl;
  final String heroId;
  final double height;
  final double? width;
  final bool showGradient;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const CafeImage({
    super.key,
    required this.heroId,
    this.imageUrl,
    this.height = 180,
    this.width,
    this.showGradient = false,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.zero;

    Widget imageWidget;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        placeholder: (_, __) => ShimmerCard(
          height: height,
          width: width,
          borderRadius: br.topLeft.x,
        ),
        errorWidget: (_, __, ___) => _Placeholder(
          height: height,
          width: width,
          borderRadius: br,
        ),
      );
    } else {
      imageWidget = _Placeholder(
        height: height,
        width: width,
        borderRadius: br,
      );
    }

    return Hero(
      tag: 'cafe_image_$heroId',
      child: ClipRRect(
        borderRadius: br,
        child: Stack(
          children: [
            imageWidget,
            if (showGradient)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const _Placeholder({
    required this.height,
    this.width,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        color: AppTheme.primary.withOpacity(0.08),
        child: const Center(
          child: Icon(
            Icons.local_cafe_rounded,
            size: 48,
            color: AppTheme.primaryLight,
          ),
        ),
      ),
    );
  }
}
