import 'package:cloud_firestore/cloud_firestore.dart';

class SkillPostModel {
  final String id;
  final String userId;
  final String userName;
  final String skillOffered;
  final String skillWanted;
  final String description;
  final String contactInfo;
  final DateTime createdAt;

  SkillPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.skillOffered,
    required this.skillWanted,
    required this.description,
    required this.contactInfo,
    required this.createdAt,
  });

  factory SkillPostModel.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['createdAt'];
    DateTime created = rawDate is Timestamp ? rawDate.toDate() : DateTime.now();

    return SkillPostModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'User',
      skillOffered: map['skillOffered'] as String? ?? '',
      skillWanted: map['skillWanted'] as String? ?? '',
      description: map['description'] as String? ?? '',
      contactInfo: map['contactInfo'] as String? ?? '',
      createdAt: created,
    );
  }
}