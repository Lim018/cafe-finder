part of 'place_detail_bloc.dart';

abstract class PlaceDetailEvent extends Equatable {
  const PlaceDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadPlaceDetail extends PlaceDetailEvent {
  final int id;

  /// When true, skip the loading state if data is already loaded — refresh
  /// in place so the existing tree (Hero image, PageView) isn't torn down.
  final bool silent;

  const LoadPlaceDetail(this.id, {this.silent = false});

  @override
  List<Object> get props => [id, silent];
}
