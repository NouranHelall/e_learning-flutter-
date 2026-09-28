import 'package:e_learning/features/matching/data/models/match_model.dart';
import 'package:e_learning/features/profile/data/models/user_skill_model.dart';

class ExploreState {
  final bool isLoading;
  final List<MatchModel> people;
  final String query;
  final SkillLevel? level;
  final bool topRated;
  final String? error;

  const ExploreState({
    required this.isLoading,
    required this.people,
    required this.query,
    required this.level,
    required this.topRated,
    this.error,
  });

  factory ExploreState.initial() =>
      const ExploreState(isLoading: true, people: [], query: '', level: null, topRated: false);

  List<MatchModel> get results {
    final q = query.trim().toLowerCase();

    final list = people.where((match) {
      if (q.isNotEmpty) {
        final inName = match.user.name.toLowerCase().contains(q);
        final inSkills = match.user.skillsKnown.any((s) => s.name.toLowerCase().contains(q));
        if (!inName && !inSkills) return false;
      }
      if (level != null && !match.user.skillsKnown.any((s) => s.level == level)) return false;
      if (topRated && match.user.ratingAverage < 4) return false;
      return true;
    }).toList();

    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  List<String> get quickSkills {
    final counts = <String, int>{};
    for (final match in people) {
      for (final skill in match.user.skillsKnown) {
        counts[skill.name] = (counts[skill.name] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(4).map((entry) => entry.key).toList();
  }

  ExploreState copyWith({
    bool? isLoading,
    List<MatchModel>? people,
    String? query,
    SkillLevel? level,
    bool clearLevel = false,
    bool? topRated,
    String? error,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      people: people ?? this.people,
      query: query ?? this.query,
      level: clearLevel ? null : (level ?? this.level),
      topRated: topRated ?? this.topRated,
      error: error,
    );
  }
}