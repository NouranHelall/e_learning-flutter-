import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String exchangeId;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.exchangeId,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['createdAt'];
    return ReviewModel(
      id: id,
      exchangeId: map['exchangeId'] as String? ?? '',
      fromUserId: map['fromUserId'] as String? ?? '',
      fromUserName: map['fromUserName'] as String? ?? '',
      toUserId: map['toUserId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: map['comment'] as String? ?? '',
      createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
    );
  }
}