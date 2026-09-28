import 'package:e_learning/features/auth/data/models/app_user_model.dart';
import 'package:e_learning/features/profile/data/models/user_skill_model.dart';

class MatchModel {
  final AppUserModel user;
  final List<String> theyTeachYouWant;
  final List<String> youTeachTheyWant;

  const MatchModel({
    required this.user,
    required this.theyTeachYouWant,
    required this.youTeachTheyWant,
  });

  factory MatchModel.between(AppUserModel me, AppUserModel other) {
    final myKnown = me.skillsKnown.map((e) => e.name.toLowerCase().trim()).toSet();
    final myWanted = me.skillsWanted.map((e) => e.toLowerCase().trim()).toSet();

    return MatchModel(
      user: other,
      theyTeachYouWant: other.skillsKnown
          .where((s) => myWanted.contains(s.name.toLowerCase().trim()))
          .map((s) => s.name)
          .toList(),
      youTeachTheyWant: other.skillsWanted.where((s) => myKnown.contains(s.toLowerCase().trim())).toList(),
    );
  }

  bool get isMutual => theyTeachYouWant.isNotEmpty && youTeachTheyWant.isNotEmpty;

  int get score {
    var value = 20;
    if (theyTeachYouWant.isNotEmpty) value += theyTeachYouWant.length > 1 ? 40 : 35;
    if (youTeachTheyWant.isNotEmpty) value += youTeachTheyWant.length > 1 ? 30 : 25;
    value += (user.ratingAverage / 5 * 10).round();
    return value.clamp(0, 99);
  }

  List<String> get canTeach =>
      theyTeachYouWant.isNotEmpty ? theyTeachYouWant : user.skillsKnown.map((s) => s.name).toList();

  List<String> get wantsToLearn => youTeachTheyWant.isNotEmpty ? youTeachTheyWant : user.skillsWanted;

  String? get headline {
    if (user.skillsKnown.isEmpty) return null;
    final skill = user.skillsKnown.first;
    return '${skill.name} · ${skill.level.label}';
  }
}