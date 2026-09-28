
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/core/networking/api_error_handler.dart';
import 'package:e_learning/core/networking/api_result.dart';
import 'package:e_learning/features/auth/data/models/app_user_model.dart';
import 'package:e_learning/features/profile/data/models/learning_goal_model.dart';
import 'package:e_learning/features/profile/data/models/user_skill_model.dart';

class UserRepo {
  final FirebaseFirestore _firestore;

  UserRepo(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<ApiResult<void>> createUserProfile(AppUserModel user) async {
    try {
      await _users.doc(user.uid).set(user.toMap());
      return const Success(null);
    } catch (e) {
      return Error(ApiErrorHandler.handle(e).message);
    }
  }

  Future<ApiResult<AppUserModel>> getUserProfile(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      final data = doc.data();

      if (!doc.exists || data == null) {
        return const Error('User profile not found');
      }

      return Success(AppUserModel.fromMap(data));
    } catch (e) {
      return Error(ApiErrorHandler.handle(e).message);
    }
  }

  Stream<AppUserModel?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      final data = doc.data();

      if (!doc.exists || data == null) return null;

      return AppUserModel.fromMap(data);
    });
  }

  Future<void> updateBio(String uid, String bio) {
    return _users.doc(uid).update({'bio': bio});
  }

  Future<void> updateSkills({
    required String uid,
    required List<UserSkillModel> skillsKnown,
    required List<String> skillsWanted,
  }) {
    return _users.doc(uid).update({
      'skillsKnown': skillsKnown.map((e) => e.toMap()).toList(),
      'skillsKnownNames':
      skillsKnown.map((e) => e.name.toLowerCase().trim()).toList(),
      'skillsWanted': skillsWanted,
    });
  }

  Future<void> updateLearningGoal(String uid, LearningGoalModel goal) {
    return _users.doc(uid).update({'learningGoal': goal.toMap()});
  }

  Future<void> updateGoalProgress(String uid, int progress) {
    return _users.doc(uid).update({'learningGoal.progress': progress});
  }

  Future<void> incrementExchangeCount(String uid) {
    return _users.doc(uid).update({
      'exchangesCount': FieldValue.increment(1),
    });
  }

  Future<void> incrementPeopleHelped(String uid) {
    return _users.doc(uid).update({
      'peopleHelped': FieldValue.increment(1),
    });
  }

  Future<void> addRating(String uid, double rating) {
    return _users.doc(uid).update({
      'ratingSum': FieldValue.increment(rating),
      'ratingCount': FieldValue.increment(1),
    });
  }

  Future<List<AppUserModel>> findTeachersForSkills(
      List<String> skillNames, {
        String? excludeUid,
      }) async {
    if (skillNames.isEmpty) return [];

    final lower =
    skillNames.map((e) => e.toLowerCase().trim()).toList();

    final snap = await _users
        .where('skillsKnownNames', arrayContainsAny: lower)
        .limit(50)
        .get();

    return snap.docs
        .map((d) => AppUserModel.fromMap(d.data()))
        .where((u) => u.uid != excludeUid)
        .toList();
  }

  Future<List<AppUserModel>> getAllUsers({
    String? excludeUid,
    int limit = 100,
  }) async {
    final snap = await _users.limit(limit).get();

    return snap.docs
        .map((d) => AppUserModel.fromMap(d.data()))
        .where((u) => u.uid != excludeUid)
        .toList();
  }
}