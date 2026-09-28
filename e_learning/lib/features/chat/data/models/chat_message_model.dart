import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatMessageType { text, session }

enum SessionProposalStatus { pending, accepted, declined }

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final ChatMessageType type;
  final List<String> readBy;
  final DateTime? sessionDate;
  final int durationMinutes;
  final SessionProposalStatus proposalStatus;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    required this.type,
    required this.readBy,
    required this.sessionDate,
    required this.durationMinutes,
    required this.proposalStatus,
  });

  bool get isSession => type == ChatMessageType.session;

  bool isReadBy(String uid) => readBy.contains(uid);

  factory ChatMessageModel.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['createdAt'];
    final rawSession = map['sessionDate'];
    final rawRead = map['readBy'];
    return ChatMessageModel(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      type: map['type'] == 'session' ? ChatMessageType.session : ChatMessageType.text,
      readBy: rawRead is List ? rawRead.map((e) => e.toString()).toList() : const [],
      sessionDate: rawSession is Timestamp ? rawSession.toDate() : null,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 60,
      proposalStatus: SessionProposalStatus.values.firstWhere(
            (e) => e.name == map['proposalStatus'],
        orElse: () => SessionProposalStatus.pending,
      ),
    );
  }
}