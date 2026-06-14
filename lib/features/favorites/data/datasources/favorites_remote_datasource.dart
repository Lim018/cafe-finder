import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../models/favorite_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<ApiResponse<List<FavoriteModel>>> getFavorites();
  Future<ApiResponse<void>> toggleFavorite(int placeId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final Dio _dio;

  FavoritesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<List<FavoriteModel>>> getFavorites() async {
    final response = await _dio.get('/favorites');
    return ApiResponse.fromJson(
      response.data,
      (jsonList) => (jsonList as List).map((json) => FavoriteModel.fromJson(json)).toList(),
    );
  }

  @override
  Future<ApiResponse<void>> toggleFavorite(int placeId) async {
    final response = await _dio.post('/favorites/places/$placeId/favorite');
    return ApiResponse(
      success: response.data['success'],
      message: response.data['message'],
      data: null,
    );
  }
}
