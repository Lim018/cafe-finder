import '../../domain/entities/place_detail.dart';

class PlaceDetailModel extends PlaceDetail {
  const PlaceDetailModel({
    required super.id,
    required super.name,
    super.description,
    required super.address,
    super.district,
    super.subdistrict,
    super.postalCode,
    required super.latitude,
    required super.longitude,
    super.priceMin,
    super.priceMax,
    super.phone,
    super.websiteUrl,
    super.instagramUrl,
    super.googleMapsUrl,
    required super.avgRating,
    required super.recommendationCount,
    required super.status,
    super.categoryName,
    super.tags = const [],
    super.openingHours = const [],
    super.photos = const [],
    super.recentReviews = const [],
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

  factory PlaceDetailModel.fromJson(Map<String, dynamic> json) {
    return PlaceDetailModel(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'] ?? '',
      district: json['district'],
      subdistrict: json['subdistrict'],
      postalCode: json['postalCode'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      priceMin: json['priceMin'] != null ? _parseDouble(json['priceMin']) : null,
      priceMax: json['priceMax'] != null ? _parseDouble(json['priceMax']) : null,
      phone: json['phone'],
      websiteUrl: json['websiteUrl'],
      instagramUrl: json['instagramUrl'],
      googleMapsUrl: json['googleMapsUrl'],
      avgRating: _parseDouble(json['avgRating']),
      recommendationCount: _parseInt(json['recommendationCount']),
      status: json['status'] ?? 'active',
      categoryName: json['category']?['name'],
      tags: json['placeTags'] != null
          ? (json['placeTags'] as List).map((t) => t['tag']['name'] as String).toList()
          : [],
      openingHours: json['openingHours'] != null
          ? (json['openingHours'] as List).map((h) => OperatingHourModel.fromJson(h)).toList()
          : [],
      photos: json['photos'] != null
          ? (json['photos'] as List).map((p) => PlacePhotoModel.fromJson(p)).toList()
          : [],
      recentReviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => PlaceReviewModel.fromJson(r)).toList()
          : [],
    );
  }
}

class OperatingHourModel extends OperatingHour {
  const OperatingHourModel({required super.dayOfWeek, required super.openTime, required super.closeTime});

  factory OperatingHourModel.fromJson(Map<String, dynamic> json) {
    return OperatingHourModel(
      dayOfWeek: json['dayOfWeek'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
    );
  }
}

class PlacePhotoModel extends PlacePhoto {
  const PlacePhotoModel({required super.id, required super.url});

  factory PlacePhotoModel.fromJson(Map<String, dynamic> json) {
    return PlacePhotoModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] as num?)?.toInt() ?? 0,
      url: json['url'],
    );
  }
}

class PlaceReviewModel extends PlaceReview {
  const PlaceReviewModel({
    required super.id,
    required super.rating,
    required super.content,
    required super.createdAt,
    required super.userName,
    super.userAvatarUrl,
  });

  factory PlaceReviewModel.fromJson(Map<String, dynamic> json) {
    return PlaceReviewModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] as num?)?.toInt() ?? 0,
      rating: json['rating'] is String ? int.tryParse(json['rating']) ?? 0 : (json['rating'] as num?)?.toInt() ?? 0,
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      userName: json['user']?['name'] ?? 'User',
      userAvatarUrl: json['user']?['avatarUrl'],
    );
  }
}
