import 'package:e_learning/features/exchanges/data/repo/exchange_repo.dart';
import 'package:e_learning/features/requests/data/models/skill_request_model.dart';
import 'package:e_learning/features/requests/data/repo/request_repo.dart';

class AcceptRequestUsecase {
  final RequestRepo _requestRepo;
  final ExchangeRepo _exchangeRepo;

  AcceptRequestUsecase(this._requestRepo, this._exchangeRepo);

  Future<String> call(SkillRequestModel request) async {
    final exchangeId = await _exchangeRepo.createExchange(
      requestId: request.id,
      userAId: request.fromUserId,
      userAName: request.fromUserName,
      userBId: request.toUserId,
      userBName: request.toUserName,
      skillAOffers: request.offeredSkill,
      skillBOffers: request.wantedSkill,
    );
    await _requestRepo.linkExchange(request.id, exchangeId);
    return exchangeId;
  }
}