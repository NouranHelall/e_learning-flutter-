import 'package:e_learning/core/networking/api_result.dart';
import 'package:e_learning/features/auth/data/user_repo.dart';
import 'package:e_learning/features/matching/data/models/match_model.dart';
import 'package:e_learning/features/profile/data/models/user_skill_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  final UserRepo _userRepo;
  final FirebaseAuth _auth;

  ExploreCubit(this._userRepo, this._auth) : super(ExploreState.initial()) {
    load();
  }

  Future<void> load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));
    final profile = await _userRepo.getUserProfile(uid);
    if (isClosed) return;

    switch (profile) {
      case Success(data: final me):
        try {
          final users = await _userRepo.getAllUsers(excludeUid: uid);
          if (isClosed) return;
          emit(
            state.copyWith(
              isLoading: false,
              people: users.map((user) => MatchModel.between(me, user)).toList(),
            ),
          );
        } catch (e) {
          if (isClosed) return;
          emit(state.copyWith(isLoading: false, error: e.toString()));
        }
      case Error(message: final message):
        emit(state.copyWith(isLoading: false, error: message));
    }
  }

  void setQuery(String value) => emit(state.copyWith(query: value));

  void setLevel(SkillLevel? level) {
    emit(level == null ? state.copyWith(clearLevel: true) : state.copyWith(level: level));
  }

  void toggleTopRated() => emit(state.copyWith(topRated: !state.topRated));
}