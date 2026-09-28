import 'package:e_learning/core/networking/api_result.dart';

import '../../../register/data/models/register_request_model.dart';
import '../../data/models/app_user_model.dart';
import '../../data/repo/auth_repo.dart';
import '../../data/user_repo.dart';


class RegisterUsecase {
  final AuthRepo _authRepo;
  final UserRepo _userRepo;
  RegisterUsecase(this._authRepo, this._userRepo);

  Future<ApiResult<String>> call(RegisterRequestModel model) async {
    final result = await _authRepo.register(model);
    switch (result) {
      case Success(data: final uid):
        await _userRepo.createUserProfile(
          AppUserModel(
            uid: uid,
            name: model.name,
            email: model.email,
            createdAt: DateTime.now(),
          ),
        );
        return Success(uid);
      case Error(message: final message):
        return Error(message);
    }
  }
}