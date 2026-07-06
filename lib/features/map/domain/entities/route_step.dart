import 'package:equatable/equatable.dart';

/// A single turn-by-turn instruction parsed from an OSRM route leg.
class RouteStep extends Equatable {
  final double distanceM;
  final double durationS;
  final String maneuverType; // e.g. depart, turn, roundabout, arrive
  final String? maneuverModifier; // e.g. left, right, slight left
  final String roadName; // street name ('' when unnamed)

  const RouteStep({
    required this.distanceM,
    required this.durationS,
    required this.maneuverType,
    this.maneuverModifier,
    required this.roadName,
  });

  @override
  List<Object?> get props =>
      [distanceM, durationS, maneuverType, maneuverModifier, roadName];
}
