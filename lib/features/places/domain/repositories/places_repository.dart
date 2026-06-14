import '../../../../core/network/api_response.dart';
import '../entities/place.dart';
import '../entities/place_detail.dart';

abstract class PlacesRepository {
  Future<ApiResponse<List<Place>>> getPlaces({
    String? search,
    int? category,
    String? district,
    String sort = 'rating',
    String order = 'desc',
    int page = 1,
    int limit = 10,
  });

  Future<ApiResponse<PlaceDetail>> getPlaceDetail(int id);
}
