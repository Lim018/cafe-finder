import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<ApiResponse<List<CategoryModel>>> getCategories();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final Dio _dio;

  CategoriesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<List<CategoryModel>>> getCategories() async {
    final response = await _dio.get('/categories');
    
    return ApiResponse.fromJson(
      response.data,
      (jsonList) => (jsonList as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList(),
    );
  }
}
