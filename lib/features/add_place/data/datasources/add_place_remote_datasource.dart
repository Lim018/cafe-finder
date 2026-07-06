import 'package:dio/dio.dart';

/// Payload for creating a place. Mirrors backend `createPlace` Joi schema
/// (src/validations/place.validation.ts).
class CreatePlacePayload {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int categoryId;
  final String? description;
  final String? district;
  final int? priceMin;
  final int? priceMax;
  final String? phone;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? googleMapsUrl;

  const CreatePlacePayload({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    this.description,
    this.district,
    this.priceMin,
    this.priceMax,
    this.phone,
    this.websiteUrl,
    this.instagramUrl,
    this.googleMapsUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'categoryId': categoryId,
    };
    // Only send optional fields when non-empty (backend allows null/'').
    void put(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      map[key] = value is String ? value.trim() : value;
    }

    put('description', description);
    put('district', district);
    put('priceMin', priceMin);
    put('priceMax', priceMax);
    put('phone', phone);
    put('websiteUrl', websiteUrl);
    put('instagramUrl', instagramUrl);
    put('googleMapsUrl', googleMapsUrl);
    return map;
  }
}

abstract class AddPlaceRemoteDataSource {
  /// Returns the created place id. Backend sets status=pending (or approved
  /// when app settings enable auto-approval).
  Future<int> createPlace(CreatePlacePayload payload);
}

class AddPlaceRemoteDataSourceImpl implements AddPlaceRemoteDataSource {
  final Dio _dio;

  AddPlaceRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<int> createPlace(CreatePlacePayload payload) async {
    final response = await _dio.post('/places', data: payload.toJson());
    final data = response.data['data'];
    // BigInt ids are serialized as strings by the backend (bigIntToJson patch).
    final rawId = data is Map ? data['id'] : null;
    return rawId is String
        ? int.tryParse(rawId) ?? 0
        : (rawId as num?)?.toInt() ?? 0;
  }
}
