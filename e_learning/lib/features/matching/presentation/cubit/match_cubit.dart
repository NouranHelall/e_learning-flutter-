import 'package:e_learning/core/networking/api_result.dart';
import 'package:e_learning/features/matching/data/repo/match_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/user_repo.dart';
import 'match_states.dart';

class MatchCubit extends Cubit<MatchState> {
  final MatchRepo _matchRepo;
  final UserRepo _userRepo;
  final FirebaseAuth _auth;

  MatchCubit(this._matchRepo, this._userRepo, this._auth) : super(MatchState.initial()) {
    loadMatches();
  }

  Future<void> loadMatches() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));
    final result = await _userRepo.getUserProfile(uid);
    if (isClosed) return;

    switch (result) {
      case Success(data: final user):
        try {
          final matches = await _matchRepo.findMatches(user);
          if (isClosed) return;
          emit(state.copyWith(isLoading: false, matches: matches));
        } catch (e) {
          if (isClosed) return;
          emit(state.copyWith(isLoading: false, error: e.toString()));
        }
      case Error(message: final message):
        emit(state.copyWith(isLoading: false, error: message));
    }
  }

  void setFilter(MatchFilter filter) => emit(state.copyWith(filter: filter));
}