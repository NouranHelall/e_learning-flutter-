enum SkillLevel { beginner, intermediate, advanced, expert }

extension SkillLevelX on SkillLevel {
  String get label {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
  }

  static SkillLevel fromName(String? name) {
    return SkillLevel.values.firstWhere(
          (e) => e.name == name,
      orElse: () => SkillLevel.beginner,
    );
  }
}

class UserSkillModel {
  final String name;
  final SkillLevel level;

  const UserSkillModel({required this.name, required this.level});

  Map<String, dynamic> toMap() {
    return {'name': name, 'level': level.name};
  }

  factory UserSkillModel.fromMap(Map<String, dynamic> map) {
    return UserSkillModel(
      name: map['name'] as String? ?? '',
      level: SkillLevelX.fromName(map['level'] as String?),
    );
  }
}