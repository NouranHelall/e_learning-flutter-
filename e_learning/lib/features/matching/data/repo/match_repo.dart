import 'package:e_learning/features/auth/data/models/app_user_model.dart';

import '../../../auth/data/user_repo.dart';
import '../models/match_model.dart';

class MatchRepo {
  final UserRepo _userRepo;

  MatchRepo(this._userRepo);

  Future<List<MatchModel>> findMatches(AppUserModel currentUser) async {
    if (currentUser.skillsWanted.isEmpty) return [];

    final candidates = await _userRepo.findTeachersForSkills(
      currentUser.skillsWanted,
      excludeUid: currentUser.uid,
    );

    final matches = candidates
        .map((candidate) => MatchModel.between(currentUser, candidate))
        .where((match) => match.theyTeachYouWant.isNotEmpty)
        .toList();

    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }
}