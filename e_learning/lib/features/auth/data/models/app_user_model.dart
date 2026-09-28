import 'package:e_learning/features/profile/data/models/learning_goal_model.dart';
import 'package:e_learning/features/profile/data/models/user_skill_model.dart';

class AppUserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final String bio;
  final List<UserSkillModel> skillsKnown;
  final List<String> skillsWanted;
  final int exchangesCount;
  final int peopleHelped;
  final double ratingSum;
  final int ratingCount;
  final LearningGoalModel learningGoal;

  AppUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.bio = '',
    this.skillsKnown = const [],
    this.skillsWanted = const [],
    this.exchangesCount = 0,
    this.peopleHelped = 0,
    this.ratingSum = 0,
    this.ratingCount = 0,
    this.learningGoal = const LearningGoalModel(
      title: '',
      targetSkill: '',
      progress: 0,
    ),
  });

  double get ratingAverage => ratingCount == 0 ? 0 : ratingSum / ratingCount;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'bio': bio,
      'skillsKnown': skillsKnown.map((e) => e.toMap()).toList(),
      'skillsKnownNames':
      skillsKnown.map((e) => e.name.toLowerCase().trim()).toList(),
      'skillsWanted': skillsWanted,
      'exchangesCount': exchangesCount,
      'peopleHelped': peopleHelped,
      'ratingSum': ratingSum,
      'ratingCount': ratingCount,
      'learningGoal': learningGoal.toMap(),
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      bio: map['bio'] as String? ?? '',
      skillsKnown: (map['skillsKnown'] as List<dynamic>? ?? [])
          .map((e) => UserSkillModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      skillsWanted: (map['skillsWanted'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      exchangesCount: (map['exchangesCount'] as num?)?.toInt() ?? 0,
      peopleHelped: (map['peopleHelped'] as num?)?.toInt() ?? 0,
      ratingSum: (map['ratingSum'] as num?)?.toDouble() ?? 0,
      ratingCount: (map['ratingCount'] as num?)?.toInt() ?? 0,
      learningGoal:
      LearningGoalModel.fromMap(map['learningGoal'] as Map<String, dynamic>?),
    );
  }
}