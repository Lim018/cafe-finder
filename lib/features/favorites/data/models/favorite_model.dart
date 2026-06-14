import '../../domain/entities/favorite.dart';

class FavoriteModel extends Favorite {
  const FavoriteModel({
    required super.id,
    required super.placeId,
    required super.placeName,
    required super.placeAddress,
    required super.avgRating,
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

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: _parseInt(json['id']),
      placeId: _parseInt(json['placeId']),
      placeName: json['place']?['name'] ?? '',
      placeAddress: json['place']?['address'] ?? '',
      avgRating: _parseDouble(json['place']?['avgRating']),
      photoUrl: (json['place']?['photos'] != null && (json['place']['photos'] as List).isNotEmpty)
          ? json['place']['photos'][0]['url']
          : null,
    );
  }
}
