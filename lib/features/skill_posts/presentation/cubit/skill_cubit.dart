import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/skill_repo.dart';
import 'skill_state.dart';

class SkillCubit extends Cubit<SkillState> {
  final SkillRepo _repo;
  final FirebaseAuth _auth;
  StreamSubscription? _sub;

  SkillCubit(this._repo, this._auth) : super(SkillState.initial()) {
    _start();
  }

  void _start() {
    final uid = _auth.currentUser?.uid;
    emit(state.copyWith(currentUid: uid));
    _sub = _repo.watchAllPosts().listen(
          (posts) => emit(state.copyWith(isLoading: false, posts: posts, error: null)),
      onError: (e) => emit(state.copyWith(isLoading: false, error: e.toString())),
    );
  }

  Future<void> addPost({
    required String skillOffered,
    required String skillWanted,
    required String description,
    required String contactInfo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final userName = (user.displayName ?? '').trim();
    await _repo.addPost(
      userId: user.uid,
      userName: userName.isEmpty ? 'User' : userName,
      skillOffered: skillOffered.trim(),
      skillWanted: skillWanted.trim(),
      description: description.trim(),
      contactInfo: contactInfo.trim(),
    );
  }

  Future<void> deletePost(String postId) async {
    await _repo.deletePost(postId);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
