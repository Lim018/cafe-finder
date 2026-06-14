import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/place_detail.dart';
import '../../domain/repositories/places_repository.dart';

part 'place_detail_event.dart';
part 'place_detail_state.dart';

class PlaceDetailBloc extends Bloc<PlaceDetailEvent, PlaceDetailState> {
  final PlacesRepository _repository;

  PlaceDetailBloc({required PlacesRepository repository})
      : _repository = repository,
        super(PlaceDetailInitial()) {
    on<LoadPlaceDetail>(_onLoadPlaceDetail);
  }

  Future<void> _onLoadPlaceDetail(LoadPlaceDetail event, Emitter<PlaceDetailState> emit) async {
    emit(PlaceDetailLoading());
    try {
      final response = await _repository.getPlaceDetail(event.id);
      if (response.data != null) {
        emit(PlaceDetailLoaded(response.data!));
      } else {
        emit(const PlaceDetailError('Place details not found'));
      }
    } catch (e) {
      emit(PlaceDetailError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
