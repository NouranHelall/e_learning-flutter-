import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/features/exchanges/data/models/exchange_model.dart';

class ExchangeRepo {
  final FirebaseFirestore _firestore;
  ExchangeRepo(this._firestore);

  CollectionReference<Map<String, dynamic>> get _exchanges =>
      _firestore.collection('exchanges');

  Future<String> createExchange({
    required String requestId,
    required String userAId,
    required String userAName,
    required String userBId,
    required String userBName,
    required String skillAOffers,
    required String skillBOffers,
  }) async {
    final doc = await _exchanges.add({
      'requestId': requestId,
      'userAId': userAId,
      'userAName': userAName,
      'userBId': userBId,
      'userBName': userBName,
      'skillAOffers': skillAOffers,
      'skillBOffers': skillBOffers,
      'sessionDate': null,
      'durationMinutes': 60,
      'mode': SessionMode.online.name,
      'status': ExchangeStatus.scheduled.name,
      'userACompleted': false,
      'userBCompleted': false,
      'meetLink': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<List<ExchangeModel>> watchExchangesFor(String uid) {
    return _exchanges
        .where(Filter.or(
      Filter('userAId', isEqualTo: uid),
      Filter('userBId', isEqualTo: uid),
    ))
        .snapshots()
        .map((snap) {
      final models = snap.docs.map((d) => ExchangeModel.fromMap(d.id, d.data())).toList();
      models.sort((a, b) {
        final aDate = a.sessionDate ?? a.createdAt;
        final bDate = b.sessionDate ?? b.createdAt;
        return bDate.compareTo(aDate);
      });
      return models;
    });
  }

  Stream<ExchangeModel?> watchExchange(String id) {
    return _exchanges.doc(id).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return ExchangeModel.fromMap(doc.id, data);
    });
  }

  Future<void> updateSchedule({
    required String exchangeId,
    required DateTime sessionDate,
    required int durationMinutes,
    required SessionMode mode,
    String? meetLink,
  }) {
    return _exchanges.doc(exchangeId).update({
      'sessionDate': Timestamp.fromDate(sessionDate),
      'durationMinutes': durationMinutes,
      'mode': mode.name,
      if (meetLink != null) 'meetLink': meetLink,
    });
  }

  Future<bool> completeForUser(String exchangeId, String uid) async {
    final docRef = _exchanges.doc(exchangeId);
    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data();
      if (data == null) return false;
      final exchange = ExchangeModel.fromMap(snapshot.id, data);
      final isUserA = uid == exchange.userAId;
      final otherCompleted = isUserA ? exchange.userBCompleted : exchange.userACompleted;

      final update = <String, dynamic>{
        isUserA ? 'userACompleted' : 'userBCompleted': true,
      };
      if (otherCompleted) {
        update['status'] = ExchangeStatus.completed.name;
      }
      transaction.update(docRef, update);
      return otherCompleted;
    });
  }
}