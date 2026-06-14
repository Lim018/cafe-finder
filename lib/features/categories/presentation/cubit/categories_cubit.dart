import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../../data/models/category_model.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepository _repository;
  final SharedPreferences _prefs;

  static const _cacheKey = 'categories_cache';
  static const _cacheTimeKey = 'categories_cache_time';
  static const _cacheDuration = Duration(hours: 1);

  CategoriesCubit({
    required CategoriesRepository repository,
    required SharedPreferences prefs,
  })  : _repository = repository,
        _prefs = prefs,
        super(CategoriesInitial());

  Future<void> loadCategories() async {
    emit(CategoriesLoading());
    
    // Check cache first
    final cachedData = _prefs.getString(_cacheKey);
    final cacheTimeStr = _prefs.getString(_cacheTimeKey);
    
    if (cachedData != null && cacheTimeStr != null) {
      final cacheTime = DateTime.parse(cacheTimeStr);
      if (DateTime.now().difference(cacheTime) < _cacheDuration) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        final categories = jsonList.map((json) => CategoryModel.fromJson(json)).toList();
        emit(CategoriesLoaded(categories));
        return;
      }
    }

    try {
      final response = await _repository.getCategories();
      if (response.data != null) {
        final categories = response.data!;
        
        // Save to cache
        final jsonList = (categories as List<CategoryModel>).map((c) => c.toJson()).toList();
        await _prefs.setString(_cacheKey, jsonEncode(jsonList));
        await _prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
        
        emit(CategoriesLoaded(categories));
      } else {
        emit(const CategoriesError('Failed to load categories'));
      }
    } catch (e) {
      // Fallback to cache if network fails, regardless of age
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        final categories = jsonList.map((json) => CategoryModel.fromJson(json)).toList();
        emit(CategoriesLoaded(categories));
      } else {
        emit(CategoriesError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }
}
