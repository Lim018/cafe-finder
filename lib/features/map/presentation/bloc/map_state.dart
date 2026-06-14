part of 'map_bloc.dart';

enum MapStatus { initial, loading, success, failure }

class MapState extends Equatable {
  final MapStatus status;
  final LatLng? currentLocation;
  final List<Place> places;
  final Place? selectedPlace;
  final List<LatLng> routePoints;
  final String errorMessage;

  const MapState({
    this.status = MapStatus.initial,
    this.currentLocation,
    this.places = const [],
    this.selectedPlace,
    this.routePoints = const [],
    this.errorMessage = '',
  });

  MapState copyWith({
    MapStatus? status,
    LatLng? currentLocation,
    List<Place>? places,
    Place? selectedPlace,
    List<LatLng>? routePoints,
    bool clearSelectedPlace = false,
    String? errorMessage,
  }) {
    return MapState(
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      places: places ?? this.places,
      selectedPlace: clearSelectedPlace ? null : (selectedPlace ?? this.selectedPlace),
      routePoints: clearSelectedPlace ? [] : (routePoints ?? this.routePoints),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentLocation,
        places,
        selectedPlace,
        routePoints,
        errorMessage,
      ];
}
