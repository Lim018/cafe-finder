part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMap extends MapEvent {}

class LoadMapPlaces extends MapEvent {
  final LatLng location;

  const LoadMapPlaces(this.location);

  @override
  List<Object?> get props => [location];
}

class SelectPlaceMarker extends MapEvent {
  final Place place;

  const SelectPlaceMarker(this.place);

  @override
  List<Object?> get props => [place];
}

class ClearSelectedPlace extends MapEvent {}
