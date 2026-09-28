import 'package:e_learning/features/profile/data/models/user_skill_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SkillFormState {
  final String name;
  final SkillLevel level;
  final bool teach;

  const SkillFormState({required this.name, required this.level, required this.teach});

  bool get canSubmit => name.trim().isNotEmpty;

  SkillFormState copyWith({String? name, SkillLevel? level, bool? teach}) {
    return SkillFormState(
      name: name ?? this.name,
      level: level ?? this.level,
      teach: teach ?? this.teach,
    );
  }
}

class SkillFormCubit extends Cubit<SkillFormState> {
  SkillFormCubit({required bool teach})
      : super(SkillFormState(name: '', level: SkillLevel.beginner, teach: teach));

  void setName(String value) => emit(state.copyWith(name: value));

  void setLevel(SkillLevel value) => emit(state.copyWith(level: value));

  void setTeach(bool value) => emit(state.copyWith(teach: value));
}