import 'package:cloud_firestore/cloud_firestore.dart';

enum ExchangeStatus { scheduled, completed, cancelled }
enum SessionMode { online, offline }

extension ExchangeStatusX on ExchangeStatus {
  static ExchangeStatus fromName(String? name) {
    return ExchangeStatus.values.firstWhere(
          (e) => e.name == name,
      orElse: () => ExchangeStatus.scheduled,
    );
  }
}

extension SessionModeX on SessionMode {
  static SessionMode fromName(String? name) {
    return SessionMode.values.firstWhere(
          (e) => e.name == name,
      orElse: () => SessionMode.online,
    );
  }
}

class ExchangeModel {
  final String id;
  final String requestId;
  final String userAId;
  final String userAName;
  final String userBId;
  final String userBName;
  final String skillAOffers;
  final String skillBOffers;
  final DateTime? sessionDate;
  final int durationMinutes;
  final SessionMode mode;
  final ExchangeStatus status;
  final bool userACompleted;
  final bool userBCompleted;
  final DateTime createdAt;
  final String meetLink;

  const ExchangeModel({
    required this.id,
    required this.requestId,
    required this.userAId,
    required this.userAName,
    required this.userBId,
    required this.userBName,
    required this.skillAOffers,
    required this.skillBOffers,
    required this.sessionDate,
    required this.durationMinutes,
    required this.mode,
    required this.status,
    required this.userACompleted,
    required this.userBCompleted,
    required this.createdAt,
    this.meetLink = '',
  });

  String otherUserId(String uid) => uid == userAId ? userBId : userAId;
  String otherUserName(String uid) => uid == userAId ? userBName : userAName;
  String skillYouGet(String uid) => uid == userAId ? skillBOffers : skillAOffers;
  String skillYouGive(String uid) => uid == userAId ? skillAOffers : skillBOffers;
  bool hasCompletedBy(String uid) => uid == userAId ? userACompleted : userBCompleted;

  factory ExchangeModel.fromMap(String id, Map<String, dynamic> map) {
    final rawCreated = map['createdAt'];
    final rawSession = map['sessionDate'];
    return ExchangeModel(
      id: id,
      requestId: map['requestId'] as String? ?? '',
      userAId: map['userAId'] as String? ?? '',
      userAName: map['userAName'] as String? ?? '',
      userBId: map['userBId'] as String? ?? '',
      userBName: map['userBName'] as String? ?? '',
      skillAOffers: map['skillAOffers'] as String? ?? '',
      skillBOffers: map['skillBOffers'] as String? ?? '',
      sessionDate: rawSession is Timestamp ? rawSession.toDate() : null,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 60,
      mode: SessionModeX.fromName(map['mode'] as String?),
      status: ExchangeStatusX.fromName(map['status'] as String?),
      userACompleted: map['userACompleted'] as bool? ?? false,
      userBCompleted: map['userBCompleted'] as bool? ?? false,
      createdAt: rawCreated is Timestamp ? rawCreated.toDate() : DateTime.now(),
      meetLink: map['meetLink'] as String? ?? '',
    );
  }
}