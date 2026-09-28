import 'dart:async';

import 'package:e_learning/features/reviews/data/models/review_model.dart';
import 'package:e_learning/features/reviews/data/repo/review_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewsState {
  final bool isLoading;
  final List<ReviewModel> reviews;

  const ReviewsState({required this.isLoading, required this.reviews});
}

class ReviewsCubit extends Cubit<ReviewsState> {
  StreamSubscription? _sub;

  ReviewsCubit(ReviewRepo repo, FirebaseAuth auth) : super(const ReviewsState(isLoading: true, reviews: [])) {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      emit(const ReviewsState(isLoading: false, reviews: []));
      return;
    }

    _sub = repo.watchReviewsFor(uid).listen(
          (reviews) => emit(ReviewsState(isLoading: false, reviews: reviews)),
      onError: (_) => emit(const ReviewsState(isLoading: false, reviews: [])),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}