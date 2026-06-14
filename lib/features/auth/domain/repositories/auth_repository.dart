import '../../../../core/network/api_response.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<ApiResponse<User>> login(String email, String password);
  Future<ApiResponse<User>> register(String name, String email, String password);
  Future<ApiResponse<void>> logout();
  Future<ApiResponse<User>> getCurrentUser();
  Future<bool> checkAuthStatus();
}
