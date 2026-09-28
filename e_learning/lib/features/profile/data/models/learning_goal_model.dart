class LearningGoalModel {
  final String title;
  final String targetSkill;
  final int progress;

  const LearningGoalModel({
    required this.title,
    required this.targetSkill,
    this.progress = 0,
  });

  bool get isSet => title.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {'title': title, 'targetSkill': targetSkill, 'progress': progress};
  }

  factory LearningGoalModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const LearningGoalModel(title: '', targetSkill: '', progress: 0);
    }
    return LearningGoalModel(
      title: map['title'] as String? ?? '',
      targetSkill: map['targetSkill'] as String? ?? '',
      progress: (map['progress'] as num?)?.toInt() ?? 0,
    );
  }
}