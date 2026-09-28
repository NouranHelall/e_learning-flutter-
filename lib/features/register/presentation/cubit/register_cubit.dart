import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_learning/core/networking/api_result.dart';
import '../../../auth/domain/usecase/register_usecase.dart';
import '../../data/models/register_request_model.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUsecase _registerUsecase;

  RegisterCubit(this._registerUsecase) : super(RegisterInitial());

  Future<void> register(RegisterRequestModel model) async {
    emit(RegisterLoading());
    final result = await _registerUsecase(model);
    switch (result) {
      case Success():
        emit(RegisterSuccess());
      case Error(message: final message):
        emit(RegisterError(message));
    }
  }
}
