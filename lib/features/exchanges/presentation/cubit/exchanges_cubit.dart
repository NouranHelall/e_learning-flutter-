import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reviews/domain/usecase/rate_exchange_usecase.dart';
import '../../data/models/exchange_model.dart';
import '../../data/repo/exchange_repo.dart';
import '../../domain/usecase/complete_exchange_usecase.dart';
import 'exchanges_states.dart';

class ExchangeDetailCubit extends Cubit<ExchangeDetailState> {
  final ExchangeRepo _exchangeRepo;
  final CompleteExchangeUsecase _completeExchangeUsecase;
  final RateExchangeUsecase _rateExchangeUsecase;
  final FirebaseAuth _auth;
  StreamSubscription? _sub;

  ExchangeDetailCubit(
      this._exchangeRepo,
      this._completeExchangeUsecase,
      this._rateExchangeUsecase,
      this._auth,
      String exchangeId,
      ) : super(ExchangeDetailState.initial()) {
    _sub = _exchangeRepo.watchExchange(exchangeId).listen(
          (exchange) => emit(state.copyWith(exchange: exchange, isLoading: false)),
    );
  }

  Future<void> schedule({
    required DateTime sessionDate,
    required int durationMinutes,
    required SessionMode mode,
    String? meetLink,
  }) async {
    final exchange = state.exchange;
    if (exchange == null) return;
    await _exchangeRepo.updateSchedule(
      exchangeId: exchange.id,
      sessionDate: sessionDate,
      durationMinutes: durationMinutes,
      mode: mode,
      meetLink: meetLink,
    );
  }

  Future<void> markCompleted() async {
    final exchange = state.exchange;
    final uid = _auth.currentUser?.uid;
    if (exchange == null || uid == null) return;
    await _completeExchangeUsecase(exchange, uid);
  }

  Future<void> submitRating({required double rating, required String comment}) async {
    final exchange = state.exchange;
    final user = _auth.currentUser;
    if (exchange == null || user == null) return;
    final toUserId = exchange.otherUserId(user.uid);
    await _rateExchangeUsecase(
      exchangeId: exchange.id,
      fromUserId: user.uid,
      fromUserName: user.displayName ?? '',
      toUserId: toUserId,
      rating: rating,
      comment: comment,
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}