import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_detail.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_remote_datasource.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource _remoteDataSource;

  PlacesRepositoryImpl({required PlacesRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ApiResponse<List<Place>>> getPlaces({
    String? search,
    int? category,
    String? district,
    String sort = 'rating',
    String order = 'desc',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _remoteDataSource.getPlaces(
        search: search,
        category: category,
        district: district,
        sort: sort,
        order: order,
        page: page,
        limit: limit,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load places');
    }
  }

  @override
  Future<ApiResponse<PlaceDetail>> getPlaceDetail(int id) async {
    try {
      return await _remoteDataSource.getPlaceDetail(id);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load place details');
    }
  }
}
