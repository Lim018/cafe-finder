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
    // Backend expects `comment` (see review.validation.ts); sending `content`
    // gets silently dropped by stripUnknown, saving an empty review.
    final response = await _dio.post('/places/$placeId/reviews', data: {
      'rating': rating,
      'comment': content,
    });
    return ApiResponse(
      success: response.data['success'],
      message: response.data['message'],
      data: null,
    );
  }
}
