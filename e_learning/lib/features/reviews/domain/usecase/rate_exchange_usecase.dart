import 'package:e_learning/features/reviews/data/repo/review_repo.dart';

import '../../../auth/data/user_repo.dart';

class RateExchangeUsecase {
  final ReviewRepo _reviewRepo;
  final UserRepo _userRepo;

  RateExchangeUsecase(this._reviewRepo, this._userRepo);

  Future<void> call({
    required String exchangeId,
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required double rating,
    required String comment,
  }) async {
    final alreadyReviewed = await _reviewRepo.hasReviewed(
      exchangeId: exchangeId,
      fromUserId: fromUserId,
    );
    if (alreadyReviewed) return;

    await _reviewRepo.addReview(
      exchangeId: exchangeId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      toUserId: toUserId,
      rating: rating,
      comment: comment,
    );
    await _userRepo.addRating(toUserId, rating);
  }
}