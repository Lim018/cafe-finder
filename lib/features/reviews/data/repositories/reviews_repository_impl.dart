import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_remote_datasource.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource _remoteDataSource;

  ReviewsRepositoryImpl({required ReviewsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ApiResponse<void>> addReview(int placeId, int rating, String content) async {
    try {
      return await _remoteDataSource.addReview(placeId, rating, content);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add review');
    }
  }
}
