import 'dart:async';

import 'package:e_learning/features/requests/presentations/cubit/requests_states.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/skill_request_model.dart';
import '../../data/repo/request_repo.dart';
import '../../domain/usecases/accept_request_usecase.dart';

class RequestCubit extends Cubit<RequestState> {
  final RequestRepo _requestRepo;
  final AcceptRequestUsecase _acceptRequestUsecase;
  final FirebaseAuth _auth;
  StreamSubscription? _incomingSub;
  StreamSubscription? _outgoingSub;

  RequestCubit(this._requestRepo, this._acceptRequestUsecase, this._auth) : super(RequestState.initial()) {
    _start();
  }

  void _start() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    _incomingSub = _requestRepo.watchIncoming(uid).listen(
          (list) => emit(state.copyWith(isLoading: false, incoming: list)),
      onError: (e) => emit(state.copyWith(isLoading: false, error: e.toString())),
    );

    _outgoingSub = _requestRepo.watchOutgoing(uid).listen(
          (list) => emit(state.copyWith(isLoading: false, outgoing: list)),
      onError: (e) => emit(state.copyWith(isLoading: false, error: e.toString())),
    );
  }

  void setTab(bool incoming) => emit(state.copyWith(showIncoming: incoming));

  Future<void> sendRequest({
    required String toUserId,
    required String toUserName,
    required String offeredSkill,
    required String wantedSkill,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _requestRepo.sendRequest(
      fromUserId: user.uid,
      fromUserName: user.displayName ?? '',
      toUserId: toUserId,
      toUserName: toUserName,
      offeredSkill: offeredSkill,
      wantedSkill: wantedSkill,
      message: message,
    );
  }

  Future<String> acceptRequest(SkillRequestModel request) => _acceptRequestUsecase(request);

  Future<void> rejectRequest(String requestId) => _requestRepo.rejectRequest(requestId);

  @override
  Future<void> close() {
    _incomingSub?.cancel();
    _outgoingSub?.cancel();
    return super.close();
  }
}