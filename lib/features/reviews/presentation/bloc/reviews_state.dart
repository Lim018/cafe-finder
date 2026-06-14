part of 'reviews_bloc.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();
  
  @override
  List<Object> get props => [];
}

class ReviewsInitial extends ReviewsState {}

class ReviewsSubmitting extends ReviewsState {}

class ReviewsSubmittedSuccess extends ReviewsState {
  final String message;

  const ReviewsSubmittedSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ReviewsError extends ReviewsState {
  final String message;

  const ReviewsError(this.message);

  @override
  List<Object> get props => [message];
}
