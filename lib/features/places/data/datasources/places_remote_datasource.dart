import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../models/place_list_item_model.dart';
import '../models/place_detail_model.dart';

abstract class PlacesRemoteDataSource {
  Future<ApiResponse<List<PlaceListItemModel>>> getPlaces({
    String? search,
    int? category,
    String? district,
    String sort = 'rating',
    String order = 'desc',
    int page = 1,
    int limit = 10,
  });

  Future<ApiResponse<PlaceDetailModel>> getPlaceDetail(int id);
}

class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  final Dio _dio;

  PlacesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<List<PlaceListItemModel>>> getPlaces({
    String? search,
    int? category,
    String? district,
    String sort = 'rating',
    String order = 'desc',
    int page = 1,
    int limit = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sort,
      'order': order,
    };

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    if (category != null) {
      queryParameters['category'] = category;
    }
    if (district != null && district.isNotEmpty) {
      queryParameters['district'] = district;
    }

    final response = await _dio.get('/places', queryParameters: queryParameters);

    return ApiResponse.fromJson(
      response.data,
      (jsonList) => (jsonList as List)
          .map((json) => PlaceListItemModel.fromJson(json))
          .toList(),
      hasMeta: true,
    );
  }

  @override
  Future<ApiResponse<PlaceDetailModel>> getPlaceDetail(int id) async {
    final response = await _dio.get('/places/$id');

    return ApiResponse.fromJson(
      response.data,
      (json) => PlaceDetailModel.fromJson(json),
    );
  }
}
