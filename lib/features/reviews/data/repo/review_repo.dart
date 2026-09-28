import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/features/reviews/data/models/review_model.dart';

class ReviewRepo {
  final FirebaseFirestore _firestore;
  ReviewRepo(this._firestore);

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('reviews');

  Stream<List<ReviewModel>> watchReviewsFor(String uid) {
    return _reviews
        .where('toUserId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ReviewModel.fromMap(d.id, d.data())).toList());
  }

  Future<bool> hasReviewed({required String exchangeId, required String fromUserId}) async {
    final snap = await _reviews
        .where('exchangeId', isEqualTo: exchangeId)
        .where('fromUserId', isEqualTo: fromUserId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> addReview({
    required String exchangeId,
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required double rating,
    required String comment,
  }) {
    return _reviews.add({
      'exchangeId': exchangeId,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}