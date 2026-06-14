part of 'place_detail_bloc.dart';

abstract class PlaceDetailEvent extends Equatable {
  const PlaceDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadPlaceDetail extends PlaceDetailEvent {
  final int id;

  const LoadPlaceDetail(this.id);

  @override
  List<Object> get props => [id];
}
