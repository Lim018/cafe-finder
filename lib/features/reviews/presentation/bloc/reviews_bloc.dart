import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/reviews_repository.dart';

part 'reviews_event.dart';
part 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final ReviewsRepository _repository;

  ReviewsBloc({required ReviewsRepository repository})
      : _repository = repository,
        super(ReviewsInitial()) {
    on<SubmitReview>(_onSubmitReview);
  }

  Future<void> _onSubmitReview(SubmitReview event, Emitter<ReviewsState> emit) async {
    emit(ReviewsSubmitting());
    try {
      await _repository.addReview(event.placeId, event.rating, event.content);
      emit(const ReviewsSubmittedSuccess('Review added successfully'));
    } catch (e) {
      emit(ReviewsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
