import 'dart:async';

import 'package:e_learning/features/notifications/data/repo/notification_repo.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notification_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo _notificationRepo;
  final FirebaseAuth _auth;

  StreamSubscription? _subscription;

  NotificationCubit(this._notificationRepo, this._auth)
      : super(NotificationState.initial()) {
    _start();
  }

  void _start() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    _subscription = _notificationRepo.watchNotifications(uid).listen(
          (notifications) {
        emit(
          state.copyWith(
            isLoading: false,
            notifications: notifications,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            isLoading: false,
            error: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _notificationRepo.markAsRead(
      uid: uid,
      notificationId: notificationId,
    );
  }

  Future<void> markAllAsRead() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _notificationRepo.markAllAsRead(uid);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}