import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_datasource.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource _remoteDataSource;

  CategoriesRepositoryImpl({required CategoriesRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      return await _remoteDataSource.getCategories();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load categories');
    }
  }
}
