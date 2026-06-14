import '../../domain/entities/place.dart';

class PlaceListItemModel extends Place {
  const PlaceListItemModel({
    required super.id,
    required super.name,
    required super.address,
    super.district,
    required super.latitude,
    required super.longitude,
    required super.avgRating,
    required super.recommendationCount,
    required super.status,
    super.categoryName,
    super.photoUrl,
  });

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory PlaceListItemModel.fromJson(Map<String, dynamic> json) {
    String? photo;
    if (json['photos'] != null && (json['photos'] as List).isNotEmpty) {
      photo = json['photos'][0]['url'];
    }

    return PlaceListItemModel(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      district: json['district'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      avgRating: _parseDouble(json['avgRating']),
      recommendationCount: _parseInt(json['recommendationCount']),
      status: json['status'] ?? 'active',
      categoryName: json['category']?['name'],
      photoUrl: photo,
    );
  }
}
