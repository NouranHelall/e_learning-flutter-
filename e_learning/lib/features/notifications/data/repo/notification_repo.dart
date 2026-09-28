import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationRepo {
  final FirebaseFirestore _firestore;

  NotificationRepo(this._firestore);

  CollectionReference<Map<String, dynamic>> _notifications(
      String uid,
      ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications');
  }

  Stream<List<NotificationModel>> watchNotifications(
      String uid,
      ) {
    return _notifications(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => NotificationModel.fromMap(
          doc.id,
          doc.data(),
        ),
      )
          .toList(),
    );
  }

  Future<void> markAsRead({
    required String uid,
    required String notificationId,
  }) {
    return _notifications(uid)
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead(String uid) async {
    final snapshot = await _notifications(uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(
        doc.reference,
        {'isRead': true},
      );
    }

    await batch.commit();
  }
}