import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_theme.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../bloc/places_list_bloc.dart';
import '../widgets/place_card.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class PlacesListTab extends StatefulWidget {
  const PlacesListTab({super.key});

  @override
  State<PlacesListTab> createState() => _PlacesListTabState();
}

class _PlacesListTabState extends State<PlacesListTab> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CategoriesCubit>().loadCategories();
    context.read<PlacesListBloc>().add(const LoadPlaces());
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PlacesListBloc>().add(LoadMorePlaces());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Café Finder'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari kafe...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: (value) {
                    context.read<PlacesListBloc>().add(LoadPlaces(search: value));
                  },
                ),
              ),
              BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoaded) {
                    return SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        itemCount: state.categories.length + 1,
                        itemBuilder: (context, index) {
                          final isAll = index == 0;
                          final category = isAll ? null : state.categories[index - 1];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: BlocBuilder<PlacesListBloc, PlacesListState>(
                              builder: (context, placeState) {
                                final isSelected = isAll 
                                    ? placeState.selectedCategory == 0 
                                    : placeState.selectedCategory == category!.id;
                                return ChoiceChip(
                                  label: Text(isAll ? 'Semua' : category!.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      context.read<PlacesListBloc>().add(
                                        LoadPlaces(category: isAll ? 0 : category!.id),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox(height: 50);
                },
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<PlacesListBloc, PlacesListState>(
        builder: (context, state) {
          if (state.status == PlacesListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == PlacesListStatus.failure) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.places.isEmpty) {
            return const Center(child: Text('Tidak ada kafe ditemukan.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PlacesListBloc>().add(const LoadPlaces());
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: state.hasReachedMax ? state.places.length : state.places.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.places.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final place = state.places[index];
                return PlaceCard(place: place);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final authState = context.read<AuthBloc>().state;
          if (authState is Authenticated) {
            // TODO: Navigate to add location page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Halaman Tambah Lokasi belum tersedia')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Silakan login untuk menambah lokasi')),
            );
            context.push('/login');
          }
        },
        tooltip: 'Tambah Lokasi',
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}
