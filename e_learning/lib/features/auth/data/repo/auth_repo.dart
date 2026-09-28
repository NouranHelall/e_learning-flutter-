import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_learning/core/networking/api_error_handler.dart';
import 'package:e_learning/core/networking/api_result.dart';
import '../../../login/data/models/login_request_model.dart';
import '../../../register/data/models/register_request_model.dart';



class AuthRepo {
  final FirebaseAuth _client;
  AuthRepo(this._client);

  Future<ApiResult<String>> register(RegisterRequestModel model) async {
    try {
      final credential = await _client.createUserWithEmailAndPassword(
        email: model.email,
        password: model.password,
      );
      await credential.user?.updateDisplayName(model.name);
      return Success(credential.user?.uid ?? '');
    } catch (e) {
      return Error(ApiErrorHandler.handle(e).message);
    }
  }

  Future<ApiResult<String>> login(LoginRequestModel model) async {
    try {
      final credential = await _client.signInWithEmailAndPassword(
        email: model.email,
        password: model.password,
      );
      return Success(credential.user?.uid ?? '');
    } catch (e) {
      return Error(ApiErrorHandler.handle(e).message);
    }
  }
}