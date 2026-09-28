import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/cubit/value_cubit.dart';
import 'package:e_learning/features/profile/data/models/learning_goal_model.dart';
import 'package:e_learning/features/profile/data/models/user_skill_model.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_learning/features/profile/presentation/cubit/skill_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showBioEditor(BuildContext context, String bio) {
  final cubit = context.read<ProfileCubit>();
  var value = bio;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('About you'),
      content: SingleChildScrollView(
        child: TextFormField(
          initialValue: bio,
          maxLines: 4,
          maxLength: 160,
          onChanged: (text) => value = text,
          decoration: const InputDecoration(hintText: 'Tell others what you love to teach and learn'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            cubit.updateBio(value);
            Navigator.pop(dialogContext);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> showGoalEditor(BuildContext context, LearningGoalModel goal) {
  final cubit = context.read<ProfileCubit>();
  var title = goal.title;
  var skill = goal.targetSkill;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Your Learning Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: title,
              onChanged: (text) => title = text,
              decoration: const InputDecoration(labelText: 'Goal', hintText: 'Build my first Flutter app'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: skill,
              onChanged: (text) => skill = text,
              decoration: const InputDecoration(labelText: 'Target skill', hintText: 'Flutter'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            cubit.updateLearningGoal(
              LearningGoalModel(title: title.trim(), targetSkill: skill.trim(), progress: goal.progress),
            );
            Navigator.pop(dialogContext);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> showProgressSheet(BuildContext context, LearningGoalModel goal) {
  final cubit = context.read<ProfileCubit>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider(
      create: (_) => ValueCubit<double>(goal.progress.toDouble()),
      child: _ProgressSheet(title: goal.title, onSave: cubit.updateGoalProgress),
    ),
  );
}

class _ProgressSheet extends StatelessWidget {
  final String title;
  final Future<void> Function(int) onSave;

  const _ProgressSheet({required this.title, required this.onSave});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Update your progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: c.textSecondary)),
          const SizedBox(height: 16),
          BlocBuilder<ValueCubit<double>, double>(
            builder: (context, value) => Column(
              children: [
                Text('${value.round()}%', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: c.primary)),
                Slider(
                  value: value,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${value.round()}%',
                  onChanged: context.read<ValueCubit<double>>().change,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              onSave(context.read<ValueCubit<double>>().state.round());
              Navigator.pop(context);
            },
            child: const Text('Save progress'),
          ),
        ],
      ),
    );
  }
}

Future<void> showAddSkillSheet(BuildContext context, {bool teach = true}) {
  final cubit = context.read<ProfileCubit>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider(
      create: (_) => SkillFormCubit(teach: teach),
      child: _AddSkillSheet(
        onSubmit: (form) {
          if (form.teach) {
            cubit.addKnownSkill(form.name, form.level);
          } else {
            cubit.addWantedSkill(form.name);
          }
        },
      ),
    ),
  );
}

class _AddSkillSheet extends StatelessWidget {
  final void Function(SkillFormState) onSubmit;

  const _AddSkillSheet({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: BlocBuilder<SkillFormCubit, SkillFormState>(
          builder: (context, state) {
            final cubit = context.read<SkillFormCubit>();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add a Skill', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
                const SizedBox(height: 16),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('I can teach')),
                    ButtonSegment(value: false, label: Text('I want to learn')),
                  ],
                  selected: {state.teach},
                  onSelectionChanged: (selection) => cubit.setTeach(selection.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  onChanged: cubit.setName,
                  decoration: InputDecoration(
                    labelText: 'Skill name',
                    hintText: state.teach ? 'e.g. Flutter' : 'e.g. UI/UX Design',
                  ),
                ),
                if (state.teach) ...[
                  const SizedBox(height: 16),
                  Text('Your level', style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final level in SkillLevel.values)
                        ChoiceChip(
                          label: Text(level.label),
                          selected: state.level == level,
                          onSelected: (_) => cubit.setLevel(level),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: state.canSubmit
                      ? () {
                    onSubmit(state);
                    Navigator.pop(context);
                  }
                      : null,
                  child: const Text('Add Skill'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}