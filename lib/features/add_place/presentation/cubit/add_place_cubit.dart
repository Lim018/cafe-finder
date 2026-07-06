import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/add_place_remote_datasource.dart';
import '../../domain/repositories/add_place_repository.dart';

part 'add_place_state.dart';

class AddPlaceCubit extends Cubit<AddPlaceState> {
  final AddPlaceRepository _repository;

  AddPlaceCubit({required AddPlaceRepository repository})
      : _repository = repository,
        super(const AddPlaceState());

  Future<void> submit(CreatePlacePayload payload) async {
    emit(state.copyWith(status: AddPlaceStatus.submitting, clearError: true));
    try {
      final id = await _repository.createPlace(payload);
      emit(state.copyWith(status: AddPlaceStatus.success, createdId: id));
    } catch (e) {
      emit(state.copyWith(
        status: AddPlaceStatus.failure,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
