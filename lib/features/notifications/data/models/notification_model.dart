import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? exchangeId;
  final String? requestId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.exchangeId,
    required this.requestId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    final rawCreatedAt = map['createdAt'];

    return NotificationModel(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'notifications',
      exchangeId: map['exchangeId'] as String?,
      requestId: map['requestId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : DateTime.now(),
    );
  }
}