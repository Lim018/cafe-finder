import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/place_detail_bloc.dart';
import '../widgets/place_detail_skeleton.dart';
import '../../domain/entities/place.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../map/presentation/bloc/map_bloc.dart';
import '../../../reviews/presentation/bloc/reviews_bloc.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/rating_stars.dart';
import '../../../../core/components/section_header.dart';
import '../../../../core/config/app_radius.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/config/app_typography.dart';

class PlaceDetailScreen extends StatefulWidget {
  final int placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final _pageCtrl = PageController();
  int _photoIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<PlaceDetailBloc>().add(LoadPlaceDetail(widget.placeId));
    context.read<FavoritesBloc>().add(LoadFavorites());
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _showReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      // The sheet content is its own StatefulWidget so its TextEditingController
      // is disposed at unmount (after the close animation), not on pop.
      builder: (_) => _ReviewSheet(placeId: widget.placeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewsBloc, ReviewsState>(
      listener: (context, state) {
        if (state is ReviewsSubmittedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context
              .read<PlaceDetailBloc>()
              .add(LoadPlaceDetail(widget.placeId, silent: true));
        }
      },
      child: Scaffold(
        body: BlocBuilder<PlaceDetailBloc, PlaceDetailState>(
          builder: (context, state) {
            if (state is PlaceDetailLoading) {
              return const PlaceDetailSkeleton();
            }
            if (state is PlaceDetailError) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.cloud_off_rounded, size: 56,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba lagi'),
                    onPressed: () => context.read<PlaceDetailBloc>()
                        .add(LoadPlaceDetail(widget.placeId)),
                  ),
                ]),
              );
            }

            if (state is PlaceDetailLoaded) {
              final place = state.place;
              final cs = Theme.of(context).colorScheme;

              return CustomScrollView(
                slivers: [
                  // ── Hero image ────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Photo carousel
                          place.photos.isEmpty
                              ? Container(
                                  color: cs.primaryContainer,
                                  child: Icon(Icons.local_cafe_rounded,
                                      size: 64, color: cs.primary),
                                )
                              : Hero(
                                  tag: 'cafe_image_${place.id}',
                                  child: PageView.builder(
                                    controller: _pageCtrl,
                                    itemCount: place.photos.length,
                                    onPageChanged: (i) =>
                                        setState(() => _photoIndex = i),
                                    itemBuilder: (_, i) => CachedNetworkImage(
                                      imageUrl: place.photos[i].url,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                          color: cs.primaryContainer),
                                      errorWidget: (_, __, ___) =>
                                          Container(color: cs.primaryContainer),
                                    ),
                                  ),
                                ),

                          // Gradient overlay
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.28),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.32),
                                ],
                                stops: const [0, 0.3, 0.65, 1],
                              ),
                            ),
                          ),

                          // Back button
                          Positioned(
                            top: MediaQuery.of(context).padding.top +
                                AppSpacing.sm,
                            left: AppSpacing.lg,
                            child: _CircleIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => context.pop(),
                            ),
                          ),

                          // Favorite button
                          Positioned(
                            top: MediaQuery.of(context).padding.top +
                                AppSpacing.sm,
                            right: AppSpacing.lg,
                            child: BlocBuilder<FavoritesBloc, FavoritesState>(
                              builder: (_, favState) {
                                final isFav = favState is FavoritesLoaded &&
                                    favState.favorites
                                        .any((f) => f.placeId == place.id);
                                return _CircleIconButton(
                                  icon: isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  iconColor: isFav ? AppTheme.heartColor : null,
                                  onTap: () => context
                                      .read<FavoritesBloc>()
                                      .add(ToggleFavorite(place.id)),
                                );
                              },
                            ),
                          ),

                          // Photo page indicators
                          if (place.photos.length > 1)
                            Positioned(
                              bottom: AppSpacing.md,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                    place.photos.length,
                                    (i) => AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 280),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          width: i == _photoIndex ? 18 : 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: i == _photoIndex
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        )),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── Content ───────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.xl),

                          // ── Title + rating ──────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(place.name,
                                          style: AppTypography
                                              .textTheme.displaySmall
                                              ?.copyWith(color: cs.onSurface)),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 15, color: cs.onSurfaceVariant),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            [place.district, place.address]
                                                .where((s) => s != null && s.isNotEmpty)
                                                .join(' · '),
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
                                const SizedBox(width: AppSpacing.md),
                                // Rating card
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(children: [
                                    Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.star_rounded,
                                          size: 16, color: AppTheme.starColor),
                                      const SizedBox(width: 3),
                                      Text(place.avgRating.toStringAsFixed(1),
                                          style: AppTypography.textTheme.titleLarge
                                              ?.copyWith(color: cs.onSurface)),
                                    ]),
                                    Text('${place.reviewCount} ulasan',
                                        style: AppTypography.textTheme.labelSmall
                                            ?.copyWith(color: cs.onSurfaceVariant)),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Action buttons ──────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl),
                            child: Row(children: [
                              if (place.googleMapsUrl != null)
                                Expanded(
                                  child: FilledButton.icon(
                                    icon: const Icon(Icons.directions_rounded, size: 18),
                                    label: const Text('Rute'),
                                    onPressed: () =>
                                        _launch(place.googleMapsUrl!),
                                  ),
                                ),
                              if (place.googleMapsUrl != null)
                                const SizedBox(width: AppSpacing.sm),
                              if (place.instagramUrl != null)
                                _ActionBtn(
                                    icon: Icons.photo_camera_outlined,
                                    onTap: () => _launch(place.instagramUrl!)),
                              if (place.websiteUrl != null) ...[
                                const SizedBox(width: AppSpacing.sm),
                                _ActionBtn(
                                    icon: Icons.language_rounded,
                                    onTap: () => _launch(place.websiteUrl!)),
                              ],
                              if (place.phone != null) ...[
                                const SizedBox(width: AppSpacing.sm),
                                _ActionBtn(
                                    icon: Icons.call_outlined,
                                    onTap: () =>
                                        _launch('tel:${place.phone}')),
                              ],
                            ]),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Category chip ────────────────────────────
                          if (place.categoryName != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
                              child: Wrap(children: [
                                Chip(
                                  label: Text(place.categoryName!),
                                  backgroundColor: cs.primaryContainer,
                                  labelStyle: AppTypography.textTheme.labelMedium
                                      ?.copyWith(color: cs.onPrimaryContainer,
                                          fontWeight: FontWeight.w600),
                                  side: BorderSide.none,
                                ),
                              ]),
                            ),

                          // ── Lihat lokasi di peta ─────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xl, AppSpacing.sm,
                                AppSpacing.xl, AppSpacing.md),
                            child: AppButton(
                              label: 'Lihat di Peta',
                              icon: const Icon(Icons.map_outlined, size: 18),
                              onPressed: () {
                                context.read<MapBloc>().add(FocusPlace(Place(
                                      id: place.id,
                                      name: place.name,
                                      address: place.address,
                                      district: place.district,
                                      latitude: place.latitude,
                                      longitude: place.longitude,
                                      avgRating: place.avgRating,
                                      recommendationCount:
                                          place.recommendationCount,
                                      status: place.status,
                                      categoryName: place.categoryName,
                                      photoUrl: place.photos.isNotEmpty
                                          ? place.photos.first.url
                                          : null,
                                    )));
                                context.go('/map');
                              },
                            ),
                          ),

                          // ── Description ─────────────────────────────
                          if (place.description != null) ...[
                            SectionHeader(title: 'Tentang'),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl, AppSpacing.sm,
                                  AppSpacing.xl, AppSpacing.xl),
                              child: Text(place.description!,
                                  style: AppTypography.textTheme.bodyMedium
                                      ?.copyWith(color: cs.onSurface, height: 1.6)),
                            ),
                          ],

                          // ── Facilities ───────────────────────────────
                          if (place.tags.isNotEmpty) ...[
                            SectionHeader(title: 'Fasilitas'),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl, AppSpacing.sm,
                                  AppSpacing.xl, AppSpacing.xl),
                              child: Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: place.tags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm - 2),
                                    decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius: AppRadius.pillAll,
                                      border: Border.all(color: cs.outlineVariant),
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.check_circle_outline_rounded,
                                          size: 14, color: cs.primary),
                                      const SizedBox(width: 5),
                                      Text(tag,
                                          style: AppTypography.textTheme.labelMedium
                                              ?.copyWith(color: cs.onSurface)),
                                    ]),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

                          // ── Rating distribution ──────────────────────
                          if (place.recentReviews.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl),
                              child: _RatingDistribution(
                                avgRating: place.avgRating,
                                recentReviews: place.recentReviews,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],

                          // ── Reviews ──────────────────────────────────
                          SectionHeader(
                            title: 'Ulasan',
                            trailing: TextButton.icon(
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Tulis'),
                              onPressed: _showReviewSheet,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          if (place.recentReviews.isEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl, AppSpacing.md,
                                  AppSpacing.xl, AppSpacing.xl),
                              child: Text('Belum ada ulasan.',
                                  style: AppTypography.textTheme.bodyMedium
                                      ?.copyWith(color: cs.onSurfaceVariant)),
                            )
                          else
                            ...place.recentReviews.map(
                              (rev) => Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.xl, 0,
                                    AppSpacing.xl, AppSpacing.md),
                                child: _ReviewCard(review: rev),
                              ),
                            ),

                          // Bottom padding for floating nav
                          const SizedBox(height: AppSpacing.floatingNavHeight),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CircleIconButton(
      {required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon,
            size: 22,
            color: iconColor ?? Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  final double avgRating;
  final List recentReviews; // List<PlaceReview>

  const _RatingDistribution(
      {required this.avgRating, required this.recentReviews});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Compute counts — NOTE: approximate (only recentReviews)
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in recentReviews) {
      final rating = (r.rating as int).clamp(1, 5);
      counts[rating] = (counts[rating] ?? 0) + 1;
    }
    final total = recentReviews.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(children: [
        Column(children: [
          Text(avgRating.toStringAsFixed(1),
              style: AppTypography.textTheme.displayMedium
                  ?.copyWith(color: cs.onSurface, letterSpacing: -1)),
          RatingStars(rating: avgRating, size: 14),
          const SizedBox(height: 2),
          Text('dari ${recentReviews.length} ulasan*',
              style: AppTypography.textTheme.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ]),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            children: [5, 4, 3, 2, 1].map((star) {
              final count = counts[star] ?? 0;
              final fraction = total > 0 ? count / total : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  Text('$star',
                      style: AppTypography.textTheme.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant, fontSize: 10)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: fraction.toDouble(),
                        minHeight: 6,
                        backgroundColor: cs.outlineVariant,
                        color: AppTheme.starColor,
                      ),
                    ),
                  ),
                ]),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review; // PlaceReview

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: cs.primaryContainer,
              backgroundImage: review.userAvatarUrl != null
                  ? CachedNetworkImageProvider(review.userAvatarUrl!)
                  : null,
              child: review.userAvatarUrl == null
                  ? Icon(Icons.person_rounded,
                      color: cs.onPrimaryContainer, size: 20)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.userName,
                      style: AppTypography.textTheme.titleSmall
                          ?.copyWith(color: cs.onSurface)),
                  Row(children: [
                    RatingStars(rating: review.rating.toDouble(), size: 13),
                    const SizedBox(width: 6),
                    Text(review.createdAt,
                        style: AppTypography.textTheme.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                ],
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(review.content,
              style: AppTypography.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurface, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── Review Sheet ───────────────────────────────────────────────────────────
// Own StatefulWidget so the controller's lifecycle matches the element: it is
// disposed on unmount (after the close animation), never while the sheet is
// still rebuilding during its exit transition. Resolves Theme/MediaQuery from
// its own (sheet-route) context.
class _ReviewSheet extends StatefulWidget {
  final int placeId;
  const _ReviewSheet({required this.placeId});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  final _reviewCtrl = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _reviewCtrl.text.trim();
    final bloc = context.read<ReviewsBloc>();
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context);
    bloc.add(SubmitReview(
      placeId: widget.placeId,
      rating: _rating,
      content: content,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Tulis Ulasan',
                  style: AppTypography.textTheme.headlineMedium
                      ?.copyWith(color: cs.onSurface)),
              const SizedBox(height: 4),
              Text('Bagikan pengalamanmu di sini',
                  style: AppTypography.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.xl),
              // Interactive stars
              InteractiveRatingStars(
                initialRating: _rating,
                size: 44,
                onRatingChanged: (r) => _rating = r,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Review text
              TextField(
                controller: _reviewCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ceritakan pengalaman kamu…',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Submit
              AppButton(label: 'Kirim Ulasan', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
