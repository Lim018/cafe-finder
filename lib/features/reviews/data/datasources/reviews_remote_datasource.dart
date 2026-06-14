import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';

abstract class ReviewsRemoteDataSource {
  Future<ApiResponse<void>> addReview(int placeId, int rating, String content);
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final Dio _dio;

  ReviewsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<void>> addReview(int placeId, int rating, String content) async {
    final response = await _dio.post('/places/$placeId/reviews', data: {
      'rating': rating,
      'content': content,
    });
    return ApiResponse(
      success: response.data['success'],
      message: response.data['message'],
      data: null,
    );
  }
}
