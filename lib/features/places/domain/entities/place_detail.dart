import 'package:equatable/equatable.dart';

class PlaceDetail extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String address;
  final String? district;
  final String? subdistrict;
  final String? postalCode;
  final double latitude;
  final double longitude;
  final double? priceMin;
  final double? priceMax;
  final String? phone;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? googleMapsUrl;
  final double avgRating;
  final int reviewCount;
  final int recommendationCount;
  final String status;
  final String? categoryName;
  final List<String> tags;
  final List<OperatingHour> openingHours;
  final List<PlacePhoto> photos;
  final List<PlaceReview> recentReviews;

  const PlaceDetail({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    this.district,
    this.subdistrict,
    this.postalCode,
    required this.latitude,
    required this.longitude,
    this.priceMin,
    this.priceMax,
    this.phone,
    this.websiteUrl,
    this.instagramUrl,
    this.googleMapsUrl,
    required this.avgRating,
    this.reviewCount = 0,
    required this.recommendationCount,
    required this.status,
    this.categoryName,
    this.tags = const [],
    this.openingHours = const [],
    this.photos = const [],
    this.recentReviews = const [],
  });

  @override
  List<Object?> get props => [
        id, name, description, address, district, subdistrict, postalCode, latitude, longitude,
        priceMin, priceMax, phone, websiteUrl, instagramUrl, googleMapsUrl,
        avgRating, reviewCount, recommendationCount, status, categoryName, tags, openingHours, photos, recentReviews,
      ];
}

class OperatingHour extends Equatable {
  final int dayOfWeek;
  final String openTime;
  final String closeTime;

  const OperatingHour({required this.dayOfWeek, required this.openTime, required this.closeTime});

  @override
  List<Object?> get props => [dayOfWeek, openTime, closeTime];
}

class PlacePhoto extends Equatable {
  final int id;
  final String url;

  const PlacePhoto({required this.id, required this.url});

  @override
  List<Object?> get props => [id, url];
}

class PlaceReview extends Equatable {
  final int id;
  final int rating;
  final String content;
  final String createdAt;
  final String userName;
  final String? userAvatarUrl;

  const PlaceReview({
    required this.id,
    required this.rating,
    required this.content,
    required this.createdAt,
    required this.userName,
    this.userAvatarUrl,
  });

  @override
  List<Object?> get props => [id, rating, content, createdAt, userName, userAvatarUrl];
}
