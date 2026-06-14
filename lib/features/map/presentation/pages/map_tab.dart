import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/map_bloc.dart';
import '../../../places/presentation/widgets/place_card.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(InitializeMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state.status == MapStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == MapStatus.initial || state.status == MapStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final initialPosition = state.currentLocation ?? const LatLng(-6.200000, 106.816666); // Default Jakarta

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialPosition,
                  initialZoom: 14.0,
                  onTap: (_, __) {
                    context.read<MapBloc>().add(ClearSelectedPlace());
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.cafe_finder',
                  ),
                  if (state.routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: state.places.map((place) {
                      return Marker(
                        point: LatLng(place.latitude, place.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            context.read<MapBloc>().add(SelectPlaceMarker(place));
                          },
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (state.currentLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: state.currentLocation!,
                          width: 20,
                          height: 20,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                ],
              ),
              Positioned(
                top: 50,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    if (state.currentLocation != null) {
                      _mapController.move(state.currentLocation!, 15.0);
                    }
                  },
                ),
              ),
              if (state.selectedPlace != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: PlaceCard(place: state.selectedPlace!),
                ),
            ],
          );
        },
      ),
    );
  }
}
