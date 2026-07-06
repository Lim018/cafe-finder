part of 'map_bloc.dart';

enum MapStatus { initial, loading, success, failure }

class MapState extends Equatable {
  final MapStatus status;
  final LatLng? currentLocation;
  final List<Place> places;
  final Place? selectedPlace;
  final List<LatLng> routePoints;
  final String errorMessage;
  // One-shot camera target set by FocusPlace (from the detail "Lihat di Peta"
  // button); cleared once the map has moved there.
  final LatLng? focusTarget;
  // Route metrics for the selected place (driving profile from OSRM).
  final double routeDistanceM;
  final double routeDurationS; // car/driving duration
  final List<RouteStep> routeSteps;

  const MapState({
    this.status = MapStatus.initial,
    this.currentLocation,
    this.places = const [],
    this.selectedPlace,
    this.routePoints = const [],
    this.errorMessage = '',
    this.focusTarget,
    this.routeDistanceM = 0,
    this.routeDurationS = 0,
    this.routeSteps = const [],
  });

  MapState copyWith({
    MapStatus? status,
    LatLng? currentLocation,
    List<Place>? places,
    Place? selectedPlace,
    List<LatLng>? routePoints,
    bool clearSelectedPlace = false,
    String? errorMessage,
    LatLng? focusTarget,
    bool clearFocusTarget = false,
    double? routeDistanceM,
    double? routeDurationS,
    List<RouteStep>? routeSteps,
  }) {
    return MapState(
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      places: places ?? this.places,
      selectedPlace: clearSelectedPlace ? null : (selectedPlace ?? this.selectedPlace),
      routePoints: clearSelectedPlace ? [] : (routePoints ?? this.routePoints),
      errorMessage: errorMessage ?? this.errorMessage,
      focusTarget: clearFocusTarget ? null : (focusTarget ?? this.focusTarget),
      routeDistanceM:
          clearSelectedPlace ? 0 : (routeDistanceM ?? this.routeDistanceM),
      routeDurationS:
          clearSelectedPlace ? 0 : (routeDurationS ?? this.routeDurationS),
      routeSteps: clearSelectedPlace ? const [] : (routeSteps ?? this.routeSteps),
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
        focusTarget,
        routeDistanceM,
        routeDurationS,
        routeSteps,
      ];
}
