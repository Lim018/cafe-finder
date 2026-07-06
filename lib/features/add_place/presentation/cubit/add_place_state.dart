part of 'add_place_cubit.dart';

enum AddPlaceStatus { initial, submitting, success, failure }

class AddPlaceState extends Equatable {
  final AddPlaceStatus status;
  final String? error;
  final int? createdId;

  const AddPlaceState({
    this.status = AddPlaceStatus.initial,
    this.error,
    this.createdId,
  });

  AddPlaceState copyWith({
    AddPlaceStatus? status,
    String? error,
    int? createdId,
    bool clearError = false,
  }) {
    return AddPlaceState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      createdId: createdId ?? this.createdId,
    );
  }

  @override
  List<Object?> get props => [status, error, createdId];
}
