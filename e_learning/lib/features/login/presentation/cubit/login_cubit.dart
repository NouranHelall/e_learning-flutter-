import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_learning/core/networking/api_result.dart';
import '../../../auth/domain/usecase/login_usecase.dart';
import '../../data/models/login_request_model.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUsecase _loginUsecase;

  LoginCubit(this._loginUsecase) : super(LoginInitial());

  Future<void> login(LoginRequestModel model) async {
    emit(LoginLoading());
    final result = await _loginUsecase(model);
    switch (result) {
      case Success():
        emit(LoginSuccess());
      case Error(message: final message):
        emit(LoginError(message));
    }
  }
}
