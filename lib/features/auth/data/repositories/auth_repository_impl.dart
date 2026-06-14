import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  String _extractErrorMessage(DioException e, String defaultMessage) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data['errors'] != null) {
        return '$defaultMessage: ${data['errors']}';
      }
      if (data['error'] != null) {
        return '$defaultMessage: ${data['error']}';
      }
      if (data['message'] != null) {
        return data['message'];
      }
    }
    return e.message ?? defaultMessage;
  }

  @override
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      return await _remoteDataSource.login(email, password);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Login failed'));
    }
  }

  @override
  Future<ApiResponse<User>> register(String name, String email, String password) async {
    try {
      return await _remoteDataSource.register(name, email, password);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Registration failed'));
    }
  }

  @override
  Future<ApiResponse<void>> logout() async {
    try {
      return await _remoteDataSource.logout();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Logout failed'));
    }
  }

  @override
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get user');
    }
  }

  @override
  Future<bool> checkAuthStatus() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null) return false;
    
    try {
      await _remoteDataSource.getCurrentUser();
      return true;
    } catch (_) {
      return false;
    }
  }
}
