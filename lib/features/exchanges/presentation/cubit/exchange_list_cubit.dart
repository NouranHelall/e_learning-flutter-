import 'dart:async';

import 'package:e_learning/features/exchanges/data/repo/exchange_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'exchange_list_state.dart';

class ExchangeListCubit extends Cubit<ExchangeListState> {
  final ExchangeRepo _exchangeRepo;
  final FirebaseAuth _auth;
  StreamSubscription? _sub;

  ExchangeListCubit(this._exchangeRepo, FirebaseAuth auth)
      : _auth = auth,
        super(ExchangeListState.initial(auth.currentUser?.uid ?? '')) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    _sub = _exchangeRepo.watchExchangesFor(uid).listen(
          (list) => emit(state.copyWith(isLoading: false, exchanges: list)),
      onError: (e) => emit(state.copyWith(isLoading: false, error: e.toString())),
    );
  }

  void setFilter(ExchangeFilter filter) => emit(state.copyWith(filter: filter));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}