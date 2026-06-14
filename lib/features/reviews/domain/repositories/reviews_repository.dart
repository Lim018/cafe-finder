import '../../../../core/network/api_response.dart';

abstract class ReviewsRepository {
  Future<ApiResponse<void>> addReview(int placeId, int rating, String content);
}
