import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/features/chat/data/models/chat_message_model.dart';

class ChatRepo {
  final FirebaseFirestore _firestore;

  ChatRepo(this._firestore);

  CollectionReference<Map<String, dynamic>> _messages(String exchangeId) {
    return _firestore.collection('exchanges').doc(exchangeId).collection('messages');
  }

  Stream<List<ChatMessageModel>> watchMessages(String exchangeId) {
    return _messages(exchangeId).orderBy('createdAt').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => ChatMessageModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Stream<ChatMessageModel?> watchLastMessage(String exchangeId) {
    return _messages(exchangeId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return ChatMessageModel.fromMap(doc.id, doc.data());
    });
  }

  Future<void> sendMessage({
    required String exchangeId,
    required String senderId,
    required String senderName,
    required String text,
  }) {
    return _messages(exchangeId).add({
      'type': 'text',
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'readBy': [senderId],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendSessionProposal({
    required String exchangeId,
    required String senderId,
    required String senderName,
    required String title,
    required DateTime sessionDate,
    required int durationMinutes,
  }) {
    return _messages(exchangeId).add({
      'type': 'session',
      'senderId': senderId,
      'senderName': senderName,
      'text': title,
      'sessionDate': Timestamp.fromDate(sessionDate),
      'durationMinutes': durationMinutes,
      'proposalStatus': SessionProposalStatus.pending.name,
      'readBy': [senderId],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProposalStatus({
    required String exchangeId,
    required String messageId,
    required SessionProposalStatus status,
  }) {
    return _messages(exchangeId).doc(messageId).update({'proposalStatus': status.name});
  }

  Future<void> markRead({
    required String exchangeId,
    required String uid,
    required List<String> messageIds,
  }) {
    final batch = _firestore.batch();
    for (final id in messageIds) {
      batch.update(_messages(exchangeId).doc(id), {
        'readBy': FieldValue.arrayUnion([uid]),
      });
    }
    return batch.commit();
  }
}