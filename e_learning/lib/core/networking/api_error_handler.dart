import 'package:firebase_auth/firebase_auth.dart';

class ApiErrorHandler {
  final String message;

  ApiErrorHandler._(this.message);

  static ApiErrorHandler handle(Object error) {
    if (error is FirebaseAuthException) {
      return ApiErrorHandler._(error.message ?? 'Authentication error.');
    }

    return ApiErrorHandler._('Something went wrong. Please try again.');
  }
}