import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/features/requests/data/models/skill_request_model.dart';

class RequestRepo {
  final FirebaseFirestore _firestore;
  RequestRepo(this._firestore);

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('skill_requests');

  Stream<List<SkillRequestModel>> watchIncoming(String uid) {
    return _requests
        .where('toUserId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => SkillRequestModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<SkillRequestModel>> watchOutgoing(String uid) {
    return _requests
        .where('fromUserId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => SkillRequestModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> sendRequest({
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required String toUserName,
    required String offeredSkill,
    required String wantedSkill,
    required String message,
  }) async {
    await _requests.add({
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'offeredSkill': offeredSkill,
      'wantedSkill': wantedSkill,
      'message': message,
      'status': RequestStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'exchangeId': null,
    });
  }

  Future<void> rejectRequest(String requestId) {
    return _requests.doc(requestId).update({'status': RequestStatus.rejected.name});
  }

  Future<void> linkExchange(String requestId, String exchangeId) {
    return _requests.doc(requestId).update({
      'status': RequestStatus.accepted.name,
      'exchangeId': exchangeId,
    });
  }
}