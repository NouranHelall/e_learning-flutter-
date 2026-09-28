import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/utils/date_formatter.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_state.dart';
import 'package:e_learning/features/shell/presenation/cubit/nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final width = MediaQuery.sizeOf(context).width;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final first = (state.user?.name ?? '').trim().split(' ').first;

        final title = first.isEmpty
            ? DateFormatter.greeting()
            : '${DateFormatter.greeting()}, $first';

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: width < 600 ? 22 : 26,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to exchange knowledge today?',
                    style: TextStyle(
                      fontSize: width < 600 ? 13 : 14,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => context.read<NavCubit>().select(2),
              customBorder: const CircleBorder(),
              child: Container(
                width: width < 600 ? 40 : 44,
                height: width < 600 ? 40 : 44,
                decoration: BoxDecoration(
                  color: c.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}