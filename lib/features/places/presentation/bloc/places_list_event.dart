part of 'places_list_bloc.dart';

abstract class PlacesListEvent extends Equatable {
  const PlacesListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlaces extends PlacesListEvent {
  final String? search;
  final int? category;

  const LoadPlaces({this.search, this.category});

  @override
  List<Object?> get props => [search, category];
}

class LoadMorePlaces extends PlacesListEvent {}
