import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/places_repository.dart';

part 'places_list_event.dart';
part 'places_list_state.dart';

class PlacesListBloc extends Bloc<PlacesListEvent, PlacesListState> {
  final PlacesRepository _repository;

  PlacesListBloc({required PlacesRepository repository})
      : _repository = repository,
        super(const PlacesListState()) {
    on<LoadPlaces>(_onLoadPlaces);
    on<LoadMorePlaces>(_onLoadMorePlaces);
  }

  Future<void> _onLoadPlaces(LoadPlaces event, Emitter<PlacesListState> emit) async {
    emit(state.copyWith(status: PlacesListStatus.loading, page: 1));

    try {
      final response = await _repository.getPlaces(
        search: event.search ?? state.searchQuery,
        category: event.category ?? state.selectedCategory,
        page: 1,
      );

      final places = response.data ?? [];
      final hasReachedMax = response.meta == null || response.meta!.page >= response.meta!.totalPages;

      emit(state.copyWith(
        status: PlacesListStatus.success,
        places: places,
        hasReachedMax: hasReachedMax,
        page: 1,
        searchQuery: event.search ?? state.searchQuery,
        selectedCategory: event.category ?? state.selectedCategory,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PlacesListStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadMorePlaces(LoadMorePlaces event, Emitter<PlacesListState> emit) async {
    if (state.hasReachedMax || state.status == PlacesListStatus.loadingMore) return;

    emit(state.copyWith(status: PlacesListStatus.loadingMore));

    try {
      final nextPage = state.page + 1;
      final response = await _repository.getPlaces(
        search: state.searchQuery,
        category: state.selectedCategory == 0 ? null : state.selectedCategory,
        page: nextPage,
      );

      final places = response.data ?? [];
      final hasReachedMax = response.meta == null || response.meta!.page >= response.meta!.totalPages;

      emit(state.copyWith(
        status: PlacesListStatus.success,
        places: List.of(state.places)..addAll(places),
        hasReachedMax: hasReachedMax,
        page: nextPage,
      ));
    } catch (e) {
      // Just revert to success state and show snackbar in UI, don't clear list
      emit(state.copyWith(
        status: PlacesListStatus.success,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
