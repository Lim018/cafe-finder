import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/place.dart';
import '../../../../core/components/cafe_image.dart';
import '../../../../core/config/app_radius.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/config/app_typography.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  /// Lokasi user untuk kalkulasi jarak — opsional.
  /// Dapatkan dari MapBloc.state.currentLocation.
  final LatLng? userLocation;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const PlaceCard({
    super.key,
    required this.place,
    this.userLocation,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  String? _distanceLabel() {
    if (userLocation == null) return place.district;
    final d = const Distance();
    final meters = d(userLocation!, LatLng(place.latitude, place.longitude));
    final dist = meters < 1000
        ? '${meters.round()} m'
        : '${(meters / 1000).toStringAsFixed(1)} km';
    return place.district != null ? '$dist · ${place.district}' : dist;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final distLabel = _distanceLabel();

    return Material(
      color: cs.surface,
      borderRadius: AppRadius.xxlAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: AppRadius.xxlAll,
        onTap: () => context.push('/place/${place.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ────────────────────────────────────────────────────
            SizedBox(
              height: 168,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CafeImage(
                    heroId: '${place.id}',
                    imageUrl: place.photoUrl,
                    height: 168,
                    showGradient: true,
                  ),

                  // Rating badge — top-left
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    child: _RatingBadge(rating: place.avgRating),
                  ),

                  // Favorite button — top-right
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: _FavButton(
                      isFavorite: isFavorite,
                      onTap: onFavoriteTap,
                    ),
                  ),

                  // Distance + category — bottom
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: Row(
                      children: [
                        if (distLabel != null) ...[
                          const Icon(Icons.near_me_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              distLabel,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else
                          const Spacer(),
                        if (place.categoryName != null)
                          _CategoryBadge(label: place.categoryName!),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md,
                  AppSpacing.lg, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTypography.textTheme.titleLarge
                        ?.copyWith(color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        place.address,
                        style: AppTypography.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: AppRadius.pillAll,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star_rounded, size: 14, color: AppTheme.starColor),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF211C18)),
        ),
      ]),
    );
  }
}

class _FavButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  const _FavButton({required this.isFavorite, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 20,
          color: isFavorite ? AppTheme.heartColor : const Color(0xFFB5ADA3),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 1, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6F4E37)),
      ),
    );
  }
}
