part of 'places_list_bloc.dart';

enum PlacesListStatus { initial, loading, success, failure, loadingMore }

class PlacesListState extends Equatable {
  final PlacesListStatus status;
  final List<Place> places;
  final bool hasReachedMax;
  final String errorMessage;
  final int page;
  final String searchQuery;
  final int selectedCategory;

  const PlacesListState({
    this.status = PlacesListStatus.initial,
    this.places = const <Place>[],
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.page = 1,
    this.searchQuery = '',
    this.selectedCategory = 0,
  });

  PlacesListState copyWith({
    PlacesListStatus? status,
    List<Place>? places,
    bool? hasReachedMax,
    String? errorMessage,
    int? page,
    String? searchQuery,
    int? selectedCategory,
  }) {
    return PlacesListState(
      status: status ?? this.status,
      places: places ?? this.places,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object> get props => [
        status,
        places,
        hasReachedMax,
        errorMessage,
        page,
        searchQuery,
        selectedCategory,
      ];
}
