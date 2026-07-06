import 'package:dio/dio.dart';
import '../../domain/repositories/add_place_repository.dart';
import '../datasources/add_place_remote_datasource.dart';

class AddPlaceRepositoryImpl implements AddPlaceRepository {
  final AddPlaceRemoteDataSource _remoteDataSource;

  AddPlaceRepositoryImpl({required AddPlaceRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<int> createPlace(CreatePlacePayload payload) async {
    try {
      return await _remoteDataSource.createPlace(payload);
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Gagal menambahkan lokasi';
      if (data is Map) {
        // Validation errors come back as { errors: { field: [msg] } }.
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          message = first is List && first.isNotEmpty
              ? first.first.toString()
              : (data['message']?.toString() ?? message);
        } else if (data['message'] != null) {
          message = data['message'].toString();
        }
      }
      throw Exception(message);
    }
  }
}
