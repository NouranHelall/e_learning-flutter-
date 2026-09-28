import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/widgets/common/app_card.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_state.dart';
import 'package:e_learning/features/profile/presentation/ui/profile_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveTrackSection extends StatelessWidget {
  const ActiveTrackSection({super.key});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final width = MediaQuery.sizeOf(context).width;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final user = state.user;

        if (user == null) {
          return const SizedBox.shrink();
        }

        final goal = user.learningGoal;

        if (!goal.isSet) {
          return AppCard(
            child: Row(
              children: [
                Container(
                  width: width < 600 ? 42 : 46,
                  height: width < 600 ? 42 : 46,
                  decoration: BoxDecoration(
                    color: c.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: c.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set your learning goal',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track your progress and get better matches',
                        style: TextStyle(
                          fontSize: width < 600 ? 11.5 : 12.5,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => showGoalEditor(context, goal),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text('Set goal'),
                ),
              ],
            ),
          );
        }

        return AppCard(
          gradient: c.heroGradient,
          borderColor: Colors.transparent,
          padding: EdgeInsets.all(width < 600 ? 15 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIVE TRACK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white70,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                goal.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width < 600 ? 18 : 20,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              if (goal.targetSkill.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Target skill: ${goal.targetSkill}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: goal.progress / 100,
                        minHeight: 8,
                        backgroundColor:
                        Colors.white.withValues(alpha: 0.25),
                        color: c.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${goal.progress}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => showProgressSheet(context, goal),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: c.primaryDark,
                    minimumSize: const Size(0, 42),
                  ),
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: const Text('Continue Goal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}