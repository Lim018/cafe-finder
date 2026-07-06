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

            // ── Scroll area: banner (scrolls away) + pinned chips + list ─
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
      child: BlocBuilder<AuthBloc, AuthState>(
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
    );
  }

  // ── Search row ───────────────────────────────────────────────────────────
  Widget _buildSearchRow(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.sm),
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

        final itemCount = state.hasReachedMax
            ? state.places.length
            : state.places.length + 1;

        return RefreshIndicator(
          color: cs.primary,
          onRefresh: () async =>
              context.read<PlacesListBloc>().add(const LoadPlaces()),
          child: CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // Banner — scrolls up and disappears.
              SliverToBoxAdapter(child: _PromoBanner()),
              // Category chips — pinned below the search bar while scrolling.
              SliverPersistentHeader(
                pinned: true,
                delegate: _ChipsHeaderDelegate(
                  background: Theme.of(context).scaffoldBackgroundColor,
                  child: _buildChips(context, cs),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.sm,
                    AppSpacing.xl, AppSpacing.floatingNavHeight),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
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
                          onFavoriteTap: () => context
                              .read<FavoritesBloc>()
                              .add(ToggleFavorite(place.id)),
                        ),
                      );
                    },
                    childCount: itemCount,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────
  Widget _buildFab(BuildContext context, ColorScheme cs) {
    // Lift FAB above the floating bottom nav bar (parent Scaffold uses
    // extendBody:true so the body extends under the nav). Matches the
    // clearance used elsewhere (map_tab, favorites, profile) — floatingNavHeight
    // already covers the nav bar's full footprint incl. safe-area inset.
    final navInset = AppSpacing.floatingNavHeight + AppSpacing.sm;
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

// ─── Pinned category chips header ────────────────────────────────────────────

class _ChipsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color background;

  _ChipsHeaderDelegate({required this.child, required this.background});

  static const double _extent = 58;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Opaque background so scrolling content passes cleanly beneath the pin.
    return Container(
      color: background,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_ChipsHeaderDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.background != background;
}

// ─── Promo Banner ──────────────────────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 2 / 1, // banner is 2:1
          child: Image.asset(
            'assets/images/SpecialCoffeeBanner.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
