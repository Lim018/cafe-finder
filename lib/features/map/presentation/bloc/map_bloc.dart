import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../places/domain/entities/place.dart';
import '../../../places/domain/repositories/places_repository.dart';
import '../../domain/entities/route_step.dart';
import 'package:dio/dio.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final PlacesRepository _placesRepository;

  MapBloc({required PlacesRepository placesRepository})
      : _placesRepository = placesRepository,
        super(const MapState()) {
    on<InitializeMap>(_onInitializeMap);
    on<LoadMapPlaces>(_onLoadMapPlaces);
    on<SelectPlaceMarker>(_onSelectPlaceMarker);
    on<ClearSelectedPlace>(_onClearSelectedPlace);
    on<FocusPlace>(_onFocusPlace);
    on<ClearFocusTarget>(_onClearFocusTarget);
  }

  Future<void> _onFocusPlace(FocusPlace event, Emitter<MapState> emit) async {
    final place = event.place;
    // Make sure the target has a marker even if it wasn't in the loaded set.
    final places = state.places.any((p) => p.id == place.id)
        ? state.places
        : [...state.places, place];
    emit(state.copyWith(
      status: MapStatus.success,
      places: places,
      focusTarget: LatLng(place.latitude, place.longitude),
    ));
    add(SelectPlaceMarker(place));
  }

  void _onClearFocusTarget(ClearFocusTarget event, Emitter<MapState> emit) {
    emit(state.copyWith(clearFocusTarget: true));
  }

  Future<void> _onInitializeMap(InitializeMap event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: MapStatus.loading));

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(
          status: MapStatus.failure,
          errorMessage: 'Location services are disabled.'));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(state.copyWith(
            status: MapStatus.failure,
            errorMessage: 'Location permissions are denied.'));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(state.copyWith(
          status: MapStatus.failure,
          errorMessage:
              'Location permissions are permanently denied, we cannot request permissions.'));
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      final currentLatLng = LatLng(position.latitude, position.longitude);

      emit(state.copyWith(
        status: MapStatus.success,
        currentLocation: currentLatLng,
      ));

      add(LoadMapPlaces(currentLatLng));
    } catch (e) {
      emit(state.copyWith(
        status: MapStatus.failure,
        errorMessage: 'Failed to get current location.',
      ));
    }
  }

  Future<void> _onLoadMapPlaces(LoadMapPlaces event, Emitter<MapState> emit) async {
    try {
      // Using arbitrary large limit for map markers
      final response = await _placesRepository.getPlaces(limit: 50);
      
      if (response.data != null) {
        emit(state.copyWith(places: response.data));
      }
    } catch (e) {
      // Ignore error for places on map for now
    }
  }

  Future<void> _onSelectPlaceMarker(SelectPlaceMarker event, Emitter<MapState> emit) async {
    emit(state.copyWith(
      selectedPlace: event.place,
      routePoints: [],
      routeDistanceM: 0,
      routeDurationS: 0,
      routeSteps: const [],
    ));
    if (state.currentLocation != null) {
      try {
        final dio = Dio(BaseOptions(headers: {
          'User-Agent': 'CafeFinderApp/1.0',
        }));
        final start = state.currentLocation!;
        final end = LatLng(event.place.latitude, event.place.longitude);
        final url =
            'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&overview=full&steps=true';
        final response = await dio.get(url);
        final routes = response.data?['routes'];
        if (routes != null && routes.isNotEmpty) {
          final route = routes[0];
          final coordinates = route['geometry']['coordinates'] as List;
          final routePoints = coordinates
              .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();

          final steps = <RouteStep>[];
          final legs = route['legs'] as List?;
          if (legs != null && legs.isNotEmpty) {
            for (final s in (legs[0]['steps'] as List? ?? [])) {
              final maneuver = s['maneuver'] ?? {};
              steps.add(RouteStep(
                distanceM: (s['distance'] as num?)?.toDouble() ?? 0,
                durationS: (s['duration'] as num?)?.toDouble() ?? 0,
                maneuverType: maneuver['type']?.toString() ?? 'continue',
                maneuverModifier: maneuver['modifier']?.toString(),
                roadName: s['name']?.toString() ?? '',
              ));
            }
          }

          emit(state.copyWith(
            routePoints: routePoints,
            routeDistanceM: (route['distance'] as num?)?.toDouble() ?? 0,
            routeDurationS: (route['duration'] as num?)?.toDouble() ?? 0,
            routeSteps: steps,
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          status: MapStatus.failure,
          errorMessage: 'Gagal mengambil rute: $e',
        ));
        // Reset status back to success after showing error
        emit(state.copyWith(status: MapStatus.success));
      }
    }
  }

  void _onClearSelectedPlace(ClearSelectedPlace event, Emitter<MapState> emit) {
    emit(state.copyWith(clearSelectedPlace: true));
  }
}
