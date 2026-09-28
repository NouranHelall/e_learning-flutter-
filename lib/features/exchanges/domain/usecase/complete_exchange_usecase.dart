import 'package:e_learning/features/exchanges/data/models/exchange_model.dart';
import 'package:e_learning/features/exchanges/data/repo/exchange_repo.dart';

import '../../../auth/data/user_repo.dart';

class CompleteExchangeUsecase {
  final ExchangeRepo _exchangeRepo;
  final UserRepo _userRepo;

  CompleteExchangeUsecase(this._exchangeRepo, this._userRepo);

  Future<void> call(ExchangeModel exchange, String uid) async {
    final bothCompleted = await _exchangeRepo.completeForUser(exchange.id, uid);
    if (bothCompleted) {
      await _userRepo.incrementExchangeCount(exchange.userAId);
      await _userRepo.incrementExchangeCount(exchange.userBId);
      await _userRepo.incrementPeopleHelped(exchange.userAId);
      await _userRepo.incrementPeopleHelped(exchange.userBId);
    }
  }
}