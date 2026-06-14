import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorites_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesBloc({required FavoritesRepository repository})
      : _repository = repository,
        super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final response = await _repository.getFavorites();
      emit(FavoritesLoaded(response.data ?? []));
    } catch (e) {
      emit(FavoritesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FavoritesState> emit) async {
    try {
      await _repository.toggleFavorite(event.placeId);
      // Reload favorites after toggling to ensure state is in sync
      add(LoadFavorites());
    } catch (e) {
      // Could emit a specific error state for UI to show a snackbar, but keeping simple
    }
  }
}
