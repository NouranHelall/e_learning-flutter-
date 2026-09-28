import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, rejected }

extension RequestStatusX on RequestStatus {
  static RequestStatus fromName(String? name) {
    return RequestStatus.values.firstWhere(
          (e) => e.name == name,
      orElse: () => RequestStatus.pending,
    );
  }
}

class SkillRequestModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final String offeredSkill;
  final String wantedSkill;
  final String message;
  final RequestStatus status;
  final DateTime createdAt;
  final String? exchangeId;

  const SkillRequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.offeredSkill,
    required this.wantedSkill,
    required this.message,
    required this.status,
    required this.createdAt,
    this.exchangeId,
  });

  factory SkillRequestModel.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['createdAt'];
    final created = rawDate is Timestamp ? rawDate.toDate() : DateTime.now();
    return SkillRequestModel(
      id: id,
      fromUserId: map['fromUserId'] as String? ?? '',
      fromUserName: map['fromUserName'] as String? ?? '',
      toUserId: map['toUserId'] as String? ?? '',
      toUserName: map['toUserName'] as String? ?? '',
      offeredSkill: map['offeredSkill'] as String? ?? '',
      wantedSkill: map['wantedSkill'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: RequestStatusX.fromName(map['status'] as String?),
      createdAt: created,
      exchangeId: map['exchangeId'] as String?,
    );
  }
}