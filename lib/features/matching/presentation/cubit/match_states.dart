import 'package:e_learning/features/matching/data/models/match_model.dart';

enum MatchFilter { all, top, mutual }

class MatchState {
  final bool isLoading;
  final List<MatchModel> matches;
  final MatchFilter filter;
  final String? error;

  const MatchState({
    required this.isLoading,
    required this.matches,
    required this.filter,
    this.error,
  });

  factory MatchState.initial() => const MatchState(isLoading: true, matches: [], filter: MatchFilter.all);

  List<MatchModel> get visible {
    switch (filter) {
      case MatchFilter.all:
        return matches;
      case MatchFilter.top:
        return matches.where((match) => match.score >= 90).toList();
      case MatchFilter.mutual:
        return matches.where((match) => match.isMutual).toList();
    }
  }

  MatchState copyWith({bool? isLoading, List<MatchModel>? matches, MatchFilter? filter, String? error}) {
    return MatchState(
      isLoading: isLoading ?? this.isLoading,
      matches: matches ?? this.matches,
      filter: filter ?? this.filter,
      error: error,
    );
  }
}