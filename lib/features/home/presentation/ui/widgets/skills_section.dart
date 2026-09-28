import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/widgets/common/pill.dart';
import 'package:e_learning/core/widgets/common/section_header.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_state.dart';
import 'package:e_learning/features/profile/presentation/ui/profile_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final user = state.user;

        if (user == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Your Skills'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final skill in user.skillsKnown)
                  Pill(
                    text: '${skill.name} · Teach',
                    color: c.primaryDark,
                    background: c.primaryLight,
                  ),
                for (final skill in user.skillsWanted)
                  Pill(
                    text: '$skill · Learning',
                    color: c.tertiaryDark,
                    background: c.tertiaryLight,
                  ),
                ActionChip(
                  avatar: Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: c.primary,
                  ),
                  label: Text(
                    'Add Skill',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.primary,
                    ),
                  ),
                  onPressed: () => showAddSkillSheet(context),
                  backgroundColor: c.card,
                  side: BorderSide(color: c.border),
                  shape: const StadiumBorder(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}