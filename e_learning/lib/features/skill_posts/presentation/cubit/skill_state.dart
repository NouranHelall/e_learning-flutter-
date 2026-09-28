import '../../data/models/skill_model.dart';

class SkillState {
  final bool isLoading;
  final List<SkillPostModel> posts;
  final String? error;
  final String? currentUid;

  const SkillState({
    required this.isLoading,
    required this.posts,
    this.error,
    this.currentUid,
  });

  factory SkillState.initial() {
    return const SkillState(isLoading: true, posts: []);
  }

  List<SkillPostModel> get myPosts =>
      posts.where((p) => p.userId == currentUid).toList();

  SkillState copyWith({
    bool? isLoading,
    List<SkillPostModel>? posts,
    String? error,
    String? currentUid,
  }) {
    return SkillState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      error: error,
      currentUid: currentUid ?? this.currentUid,
    );
  }
}
