part of 'place_detail_bloc.dart';

abstract class PlaceDetailState extends Equatable {
  const PlaceDetailState();
  
  @override
  List<Object> get props => [];
}

class PlaceDetailInitial extends PlaceDetailState {}

class PlaceDetailLoading extends PlaceDetailState {}

class PlaceDetailLoaded extends PlaceDetailState {
  final PlaceDetail place;

  const PlaceDetailLoaded(this.place);

  @override
  List<Object> get props => [place];
}

class PlaceDetailError extends PlaceDetailState {
  final String message;

  const PlaceDetailError(this.message);

  @override
  List<Object> get props => [message];
}
