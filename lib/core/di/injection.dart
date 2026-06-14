import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/categories/data/datasources/categories_remote_datasource.dart';
import '../../features/categories/data/repositories/categories_repository_impl.dart';
import '../../features/categories/domain/repositories/categories_repository.dart';
import '../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../features/places/data/datasources/places_remote_datasource.dart';
import '../../features/places/data/repositories/places_repository_impl.dart';
import '../../features/places/domain/repositories/places_repository.dart';
import '../../features/places/presentation/bloc/places_list_bloc.dart';
import '../../features/places/presentation/bloc/place_detail_bloc.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import '../../features/favorites/data/datasources/favorites_remote_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/reviews/data/datasources/reviews_remote_datasource.dart';
import '../../features/reviews/data/repositories/reviews_repository_impl.dart';
import '../../features/reviews/domain/repositories/reviews_repository.dart';
import '../../features/reviews/presentation/bloc/reviews_bloc.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';

final sl = GetIt.instance; // sl = service locator

Future<void> init() async {
  // Core
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  
  // Network
  sl.registerLazySingleton(() => AuthInterceptor(sl()));
  sl.registerLazySingleton(() => DioClient(authInterceptor: sl()));

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dio: sl<DioClient>().dio, secureStorage: sl()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl(), secureStorage: sl()));
  sl.registerFactory(() => AuthBloc(repository: sl()));

  // Categories
  sl.registerLazySingleton<CategoriesRemoteDataSource>(
      () => CategoriesRemoteDataSourceImpl(dio: sl<DioClient>().dio));
  sl.registerLazySingleton<CategoriesRepository>(
      () => CategoriesRepositoryImpl(remoteDataSource: sl()));
  sl.registerFactory(() => CategoriesCubit(repository: sl(), prefs: sl()));

  // Places
  sl.registerLazySingleton<PlacesRemoteDataSource>(
      () => PlacesRemoteDataSourceImpl(dio: sl<DioClient>().dio));
  sl.registerLazySingleton<PlacesRepository>(
      () => PlacesRepositoryImpl(remoteDataSource: sl()));
  sl.registerFactory(() => PlacesListBloc(repository: sl()));
  sl.registerFactory(() => PlaceDetailBloc(repository: sl()));

  // Map
  sl.registerFactory(() => MapBloc(placesRepository: sl()));

  // Favorites
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
      () => FavoritesRemoteDataSourceImpl(dio: sl<DioClient>().dio));
  sl.registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(remoteDataSource: sl()));
  sl.registerFactory(() => FavoritesBloc(repository: sl()));

  // Reviews
  sl.registerLazySingleton<ReviewsRemoteDataSource>(
      () => ReviewsRemoteDataSourceImpl(dio: sl<DioClient>().dio));
  sl.registerLazySingleton<ReviewsRepository>(
      () => ReviewsRepositoryImpl(remoteDataSource: sl()));
  sl.registerFactory(() => ReviewsBloc(repository: sl()));
}
