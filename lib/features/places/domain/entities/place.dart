import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final int id;
  final String name;
  final String address;
  final String? district;
  final double latitude;
  final double longitude;
  final double avgRating;
  final int recommendationCount;
  final String status;
  final String? categoryName;
  final String? photoUrl;

  const Place({
    required this.id,
    required this.name,
    required this.address,
    this.district,
    required this.latitude,
    required this.longitude,
    required this.avgRating,
    required this.recommendationCount,
    required this.status,
    this.categoryName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        district,
        latitude,
        longitude,
        avgRating,
        recommendationCount,
        status,
        categoryName,
        photoUrl,
      ];
}
