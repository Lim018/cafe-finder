part of 'reviews_bloc.dart';

abstract class ReviewsEvent extends Equatable {
  const ReviewsEvent();

  @override
  List<Object> get props => [];
}

class SubmitReview extends ReviewsEvent {
  final int placeId;
  final int rating;
  final String content;

  const SubmitReview({
    required this.placeId,
    required this.rating,
    required this.content,
  });

  @override
  List<Object> get props => [placeId, rating, content];
}
