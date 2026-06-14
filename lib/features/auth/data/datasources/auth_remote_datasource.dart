import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResponse<UserModel>> login(String email, String password);
  Future<ApiResponse<UserModel>> register(String name, String email, String password);
  Future<ApiResponse<void>> logout();
  Future<ApiResponse<UserModel>> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  AuthRemoteDataSourceImpl({required Dio dio, required SecureStorageService secureStorage})
      : _dio = dio, _secureStorage = secureStorage;

  @override
  Future<ApiResponse<UserModel>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    final data = response.data['data'];
    await _secureStorage.saveTokens(
      accessToken: data['token'],
      refreshToken: data['refreshToken'],
    );
    
    return ApiResponse.fromJson(
      response.data,
      (json) => UserModel.fromJson(json['user']),
    );
  }

  @override
  Future<ApiResponse<UserModel>> register(String name, String email, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    
    final data = response.data['data'];
    await _secureStorage.saveTokens(
      accessToken: data['token'],
      refreshToken: data['refreshToken'],
    );
    
    return ApiResponse.fromJson(
      response.data,
      (json) => UserModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return ApiResponse.fromJson(
      response.data,
      (json) => UserModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<void>> logout() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _dio.post('/auth/logout', data: {
          'refreshToken': refreshToken,
        });
      } catch (_) {
        // Ignore errors during logout on the server
      }
    }
    await _secureStorage.clearTokens();
    
    return ApiResponse(success: true, message: 'Logout successful', data: null);
  }
}
