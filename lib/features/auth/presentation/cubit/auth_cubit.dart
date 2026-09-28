import 'package:e_learning/core/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthState {
  final bool signedOut;

  const AuthState({this.signedOut = false});
}

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final NotificationService _notifications;

  AuthCubit(this._auth, this._notifications) : super(const AuthState());

  Future<void> signOut() async {
    try {
      await _notifications.unregisterDevice();
    } catch (_) {
      await _auth.signOut();
      emit(const AuthState(signedOut: true));
      return;
    }
    await _auth.signOut();
    emit(const AuthState(signedOut: true));
  }
}