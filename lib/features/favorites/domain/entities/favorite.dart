import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  final int id;
  final int placeId;
  final String placeName;
  final String placeAddress;
  final double avgRating;
  final String? photoUrl;

  const Favorite({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.placeAddress,
    required this.avgRating,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, placeId, placeName, placeAddress, avgRating, photoUrl];
}
