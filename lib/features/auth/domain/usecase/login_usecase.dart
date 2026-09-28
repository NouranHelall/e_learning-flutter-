import 'package:e_learning/core/networking/api_result.dart';
import '../../../login/data/models/login_request_model.dart';
import '../../data/repo/auth_repo.dart';


class LoginUsecase {
  final AuthRepo _authRepo;
  LoginUsecase(this._authRepo);

  Future<ApiResult<String>> call(LoginRequestModel model) {
    return _authRepo.login(model);
  }
}