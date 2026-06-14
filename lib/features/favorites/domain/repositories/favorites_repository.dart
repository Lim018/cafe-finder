import '../../../../core/network/api_response.dart';
import '../entities/favorite.dart';

abstract class FavoritesRepository {
  Future<ApiResponse<List<Favorite>>> getFavorites();
  Future<ApiResponse<void>> toggleFavorite(int placeId);
}
