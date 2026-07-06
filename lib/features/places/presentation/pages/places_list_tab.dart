import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../map/presentation/bloc/map_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../bloc/places_list_bloc.dart';
import '../widgets/place_card.dart';
import '../widgets/places_list_skeleton.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/config/app_typography.dart';

class PlacesListTab extends StatefulWidget {
  const PlacesListTab({super.key});

  @override
  State<PlacesListTab> createState() => _PlacesListTabState();
}

class _PlacesListTabState extends State<PlacesListTab> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    context.read<CategoriesCubit>().loadCategories();
    context.read<PlacesListBloc>().add(const LoadPlaces());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<PlacesListBloc>().add(LoadMorePlaces());
  }

  bool get _isBottom {
    if (!_scrollCtrl.hasClients) return false;
    return _scrollCtrl.offset >= _scrollCtrl.position.maxScrollExtent * 0.9;
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
            // ── Greeting ────────────────────────────────────────────────
            _buildGreeting(context),

            // ── Search ──────────────────────────────────────────────────
            _buildSearchRow(context, cs),

            // ── Promo banner ────────────────────────────────────────────
            _PromoBanner(),

            // ── Category chips ──────────────────────────────────────────
            _buildChips(context, cs),

            // ── List ────────────────────────────────────────────────────
            Expanded(child: _buildBody(context, cs)),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context, cs),
    );
  }

  // ── Greeting ─────────────────────────────────────────────────────────────
  Widget _buildGreeting(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (_, state) {
              final name = state is Authenticated
                  ? state.user.name.split(' ').first
                  : '';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.isNotEmpty ? 'Halo, $name 👋' : 'Halo 👋',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  Text('Temukan kafe',
                      style: AppTypography.textTheme.displaySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                ],
              );
            },
          ),
          // Notif button
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  // ── Search row ───────────────────────────────────────────────────────────
  Widget _buildSearchRow(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.sm),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            onSubmitted: (v) =>
                context.read<PlacesListBloc>().add(LoadPlaces(search: v)),
            decoration: InputDecoration(
              hintText: 'Cari kafe, area…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchCtrl,
                builder: (_, v, __) => v.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<PlacesListBloc>().add(const LoadPlaces());
                        },
                      ),
              ),
              filled: true,
              fillColor: cs.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.outlineVariant)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.outlineVariant)),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.tune_rounded, color: cs.onPrimary),
        ),
      ]),
    );
  }

  // ── Category chips ───────────────────────────────────────────────────────
  Widget _buildChips(BuildContext context, ColorScheme cs) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, catState) {
        if (catState is! CategoriesLoaded) {
          return const SizedBox(height: 50);
        }
        return BlocBuilder<PlacesListBloc, PlacesListState>(
          buildWhen: (p, c) => p.selectedCategory != c.selectedCategory,
          builder: (context, placeState) {
            return SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: catState.categories.length + 1,
                itemBuilder: (_, i) {
                  final isAll = i == 0;
                  final cat = isAll ? null : catState.categories[i - 1];
                  final isSelected = isAll
                      ? placeState.selectedCategory == 0
                      : placeState.selectedCategory == cat!.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(isAll ? 'Semua' : cat!.name),
                      selected: isSelected,
                      selectedColor: cs.primary,
                      labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
                        color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      onSelected: (sel) {
                        if (sel) {
                          context.read<PlacesListBloc>().add(
                              LoadPlaces(category: isAll ? 0 : cat!.id));
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, ColorScheme cs) {
    return BlocBuilder<PlacesListBloc, PlacesListState>(
      builder: (context, state) {
        if (state.status == PlacesListStatus.loading) {
          return const PlacesListSkeleton();
        }

        if (state.status == PlacesListStatus.failure) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.cloud_off_rounded, size: 56,
                  color: cs.onSurfaceVariant.withOpacity(0.4)),
              const SizedBox(height: AppSpacing.md),
              Text(state.errorMessage,
                  style: AppTypography.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
                onPressed: () =>
                    context.read<PlacesListBloc>().add(const LoadPlaces()),
              ),
            ]),
          );
        }

        if (state.places.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.search_off_rounded, size: 56,
                  color: cs.onSurfaceVariant.withOpacity(0.4)),
              const SizedBox(height: AppSpacing.md),
              Text('Tidak ada kafe ditemukan',
                  style: AppTypography.textTheme.headlineSmall
                      ?.copyWith(color: cs.onSurface)),
              const SizedBox(height: AppSpacing.sm),
              Text('Coba kata kunci lain',
                  style: AppTypography.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ]),
          );
        }

        // Get user location from MapBloc
        LatLng? userLoc;
        try {
          final mapState = context.read<MapBloc>().state;
          userLoc = mapState.currentLocation;
        } catch (_) {}

        // Get favorites for isFavorite state
        final favBloc = context.watch<FavoritesBloc>();
        Set<int> favIds = {};
        final favState = favBloc.state;
        if (favState is FavoritesLoaded) {
          favIds = favState.favorites.map((f) => f.placeId).toSet();
        }

        return RefreshIndicator(
          color: cs.primary,
          onRefresh: () async =>
              context.read<PlacesListBloc>().add(const LoadPlaces()),
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.sm,
                AppSpacing.xl, AppSpacing.floatingNavHeight),
            itemCount: state.hasReachedMax
                ? state.places.length
                : state.places.length + 1,
            itemBuilder: (_, i) {
              if (i >= state.places.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              final place = state.places[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: PlaceCard(
                  place: place,
                  userLocation: userLoc,
                  isFavorite: favIds.contains(place.id),
                  onFavoriteTap: () =>
                      context.read<FavoritesBloc>().add(ToggleFavorite(place.id)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────
  Widget _buildFab(BuildContext context, ColorScheme cs) {
    // Lift FAB above the floating bottom nav bar (parent Scaffold uses
    // extendBody:true so the body extends under the nav).
    final navInset = AppSpacing.floatingNavHeight +
        AppSpacing.sm +
        MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: navInset),
      child: FloatingActionButton(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onPressed: () {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          context.push('/add-place');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan login untuk menambah lokasi')),
          );
          context.push('/login');
        }
      },
        tooltip: 'Tambah Lokasi',
        child: const Icon(Icons.add_location_alt_rounded),
      ),
    );
  }
}

// ─── Promo Banner ──────────────────────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.sm),
      height: 110,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF6F4E37), Color(0xFF5A3E2B)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Promo · 08.00–11.00',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                const Text('Beli 1\nGratis 1',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.15)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Klaim sekarang',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A2719))),
                ),
              ],
            ),
          ),
        ),
        // Placeholder foto — ganti dengan Image.asset/CachedNetworkImage
        Container(
          width: 150,
          height: 110,
          color: AppTheme.primary.withOpacity(0.4),
          child: const Icon(Icons.local_cafe_rounded,
              size: 56, color: Colors.white38),
        ),
      ]),
    );
  }
}
