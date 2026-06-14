import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _remoteDataSource;

  FavoritesRepositoryImpl({required FavoritesRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ApiResponse<List<Favorite>>> getFavorites() async {
    try {
      return await _remoteDataSource.getFavorites();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load favorites');
    }
  }

  @override
  Future<ApiResponse<void>> toggleFavorite(int placeId) async {
    try {
      return await _remoteDataSource.toggleFavorite(placeId);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to toggle favorite');
    }
  }
}
