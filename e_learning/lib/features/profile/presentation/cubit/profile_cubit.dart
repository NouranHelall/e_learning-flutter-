import 'dart:async';

import 'package:e_learning/features/profile/data/models/learning_goal_model.dart';
import 'package:e_learning/features/profile/data/models/user_skill_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/user_repo.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepo _userRepo;
  final FirebaseAuth _auth;
  StreamSubscription? _sub;

  ProfileCubit(this._userRepo, this._auth) : super(ProfileState.initial()) {
    _start();
  }

  void _start() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(isLoading: false, error: 'Not signed in'));
      return;
    }

    _sub = _userRepo.watchUserProfile(uid).listen(
          (user) => emit(state.copyWith(isLoading: false, user: user)),
      onError: (e) => emit(state.copyWith(isLoading: false, error: e.toString())),
    );
  }

  Future<void> updateBio(String bio) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _userRepo.updateBio(uid, bio.trim());
  }

  Future<void> addKnownSkill(String name, SkillLevel level) async {
    final user = state.user;
    final uid = _auth.currentUser?.uid;
    final clean = name.trim();
    if (user == null || uid == null || clean.isEmpty) return;
    if (user.skillsKnown.any((s) => s.name.toLowerCase() == clean.toLowerCase())) return;

    await _userRepo.updateSkills(
      uid: uid,
      skillsKnown: [...user.skillsKnown, UserSkillModel(name: clean, level: level)],
      skillsWanted: user.skillsWanted,
    );
  }

  Future<void> addWantedSkill(String name) async {
    final user = state.user;
    final uid = _auth.currentUser?.uid;
    final clean = name.trim();
    if (user == null || uid == null || clean.isEmpty) return;
    if (user.skillsWanted.any((s) => s.toLowerCase() == clean.toLowerCase())) return;

    await _userRepo.updateSkills(
      uid: uid,
      skillsKnown: user.skillsKnown,
      skillsWanted: [...user.skillsWanted, clean],
    );
  }

  Future<void> removeKnownSkill(String name) async {
    final user = state.user;
    final uid = _auth.currentUser?.uid;
    if (user == null || uid == null) return;

    await _userRepo.updateSkills(
      uid: uid,
      skillsKnown: user.skillsKnown.where((s) => s.name != name).toList(),
      skillsWanted: user.skillsWanted,
    );
  }

  Future<void> removeWantedSkill(String name) async {
    final user = state.user;
    final uid = _auth.currentUser?.uid;
    if (user == null || uid == null) return;

    await _userRepo.updateSkills(
      uid: uid,
      skillsKnown: user.skillsKnown,
      skillsWanted: user.skillsWanted.where((s) => s != name).toList(),
    );
  }

  Future<void> updateLearningGoal(LearningGoalModel goal) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _userRepo.updateLearningGoal(uid, goal);
  }

  Future<void> updateGoalProgress(int progress) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _userRepo.updateGoalProgress(uid, progress.clamp(0, 100));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}