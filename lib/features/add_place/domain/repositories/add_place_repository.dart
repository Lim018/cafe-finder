import '../../data/datasources/add_place_remote_datasource.dart';

abstract class AddPlaceRepository {
  Future<int> createPlace(CreatePlacePayload payload);
}
