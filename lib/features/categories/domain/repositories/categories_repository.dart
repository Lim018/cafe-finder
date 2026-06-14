import '../../../../core/network/api_response.dart';
import '../entities/category.dart';

abstract class CategoriesRepository {
  Future<ApiResponse<List<Category>>> getCategories();
}
