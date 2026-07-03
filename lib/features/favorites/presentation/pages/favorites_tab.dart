import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/favorites_bloc.dart';
import '../widgets/favorites_skeleton.dart';
import '../../../../core/config/app_radius.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/config/app_typography.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Favorit Saya',
                      style: AppTypography.textTheme.displaySmall
                          ?.copyWith(color: cs.onSurface)),
                  BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (_, state) {
                      if (state is FavoritesLoaded) {
                        return Text(
                          '${state.favorites.length} kafe tersimpan',
                          style: AppTypography.textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  if (state is FavoritesLoading) {
                    return const FavoritesSkeleton();
                  }

                  if (state is FavoritesError) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.cloud_off_rounded,
                            size: 56,
                            color: cs.onSurfaceVariant.withOpacity(0.4)),
                        const SizedBox(height: AppSpacing.md),
                        Text(state.message,
                            style: AppTypography.textTheme.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton.icon(
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba lagi'),
                          onPressed: () =>
                              context.read<FavoritesBloc>().add(LoadFavorites()),
                        ),
                      ]),
                    );
                  }

                  if (state is FavoritesLoaded) {
                    if (state.favorites.isEmpty) {
                      return _EmptyFavorites();
                    }

                    return RefreshIndicator(
                      color: cs.primary,
                      onRefresh: () async =>
                          context.read<FavoritesBloc>().add(LoadFavorites()),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl, AppSpacing.xs,
                            AppSpacing.xl, AppSpacing.floatingNavHeight),
                        itemCount: state.favorites.length,
                        itemBuilder: (_, i) {
                          final fav = state.favorites[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Dismissible(
                              key: Key('fav_${fav.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: AppSpacing.xl),
                                decoration: BoxDecoration(
                                  color: cs.error,
                                  borderRadius: AppRadius.xlAll,
                                ),
                                child: Icon(Icons.delete_rounded,
                                    color: cs.onError, size: 26),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus favorit?'),
                                    content: Text(
                                        'Hapus ${fav.placeName} dari favorit kamu?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Batal'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        style: FilledButton.styleFrom(
                                            backgroundColor: cs.error),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) {
                                context
                                    .read<FavoritesBloc>()
                                    .add(ToggleFavorite(fav.placeId));
                              },
                              child: _FavoriteCard(
                                fav: fav,
                                onTap: () =>
                                    context.push('/place/${fav.placeId}'),
                                onRemove: () => context
                                    .read<FavoritesBloc>()
                                    .add(ToggleFavorite(fav.placeId)),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────

class _FavoriteCard extends StatelessWidget {
  final dynamic fav; // Favorite entity
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard(
      {required this.fav, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: AppRadius.xlAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(children: [
          // Photo
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: SizedBox(
              width: 90,
              height: 90,
              child: fav.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: fav.photoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: cs.primaryContainer,
                        child: Icon(Icons.local_cafe_rounded, color: cs.primary),
                      ),
                    )
                  : Container(
                      color: cs.primaryContainer,
                      child: Icon(Icons.local_cafe_rounded, color: cs.primary),
                    ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fav.placeName,
                      style: AppTypography.textTheme.titleSmall
                          ?.copyWith(color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: cs.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(fav.placeAddress,
                          style: AppTypography.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.star_rounded,
                        size: 14, color: AppTheme.starColor),
                    const SizedBox(width: 3),
                    Text(fav.avgRating.toStringAsFixed(1),
                        style: AppTypography.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ]),
                ],
              ),
            ),
          ),
          // Favorite (remove) button
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: IconButton(
              icon: Icon(Icons.favorite_rounded, color: AppTheme.heartColor),
              onPressed: onRemove,
            ),
          ),
        ]),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_rounded,
                  size: 52, color: cs.primary.withOpacity(0.6)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Belum ada favorit',
                style: AppTypography.textTheme.headlineMedium
                    ?.copyWith(color: cs.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Simpan kafe yang kamu suka dengan menekan ikon hati, biar gampang ditemukan lagi.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
