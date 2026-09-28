
import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/widgets/common/empaty_state.dart';
import 'package:e_learning/core/widgets/common/person_card.dart';
import 'package:e_learning/core/widgets/common/responsive_grid.dart';
import 'package:e_learning/core/widgets/common/section_header.dart';
import 'package:e_learning/features/matching/presentation/cubit/match_cubit.dart';
import 'package:e_learning/features/matching/presentation/cubit/match_states.dart';
import 'package:e_learning/features/requests/presentations/ui/request_sheet.dart';
import 'package:e_learning/features/shell/presenation/cubit/nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchesSection extends StatelessWidget {
  const MatchesSection({super.key});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return BlocBuilder<MatchCubit, MatchState>(
      builder: (context, state) {
        final sorted = [...state.matches]
          ..sort((a, b) => b.score.compareTo(a.score));

        final top = sorted.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Recommended Matches',
              badge: top.isEmpty ? null : 'Top pick',
              action: 'See all',
              onAction: () => context.read<NavCubit>().select(2),
            ),
            const SizedBox(height: 10),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.error != null)
              Text(
                state.error!,
                style: TextStyle(color: c.error),
              )
            else if (top.isEmpty)
                const EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'No matches yet',
                  subtitle: 'Add skills you want to learn to get matched',
                )
              else
                ResponsiveGrid(
                  children: [
                    for (final match in top)
                      PersonCard(
                        name: match.user.name,
                        subtitle: match.headline,
                        rating: match.user.ratingAverage,
                        exchanges: match.user.exchangesCount,
                        percent: match.score,
                        canTeach: match.canTeach,
                        wantsToLearn: match.wantsToLearn,
                        actions: [
                          FilledButton.icon(
                            onPressed: () =>
                                showRequestSheet(context, match),
                            icon: const Icon(
                              Icons.swap_horiz_rounded,
                              size: 18,
                            ),
                            label: const Text('Exchange Skills'),
                          ),
                        ],
                      ),
                  ],
                ),
          ],
        );
      },
    );
  }
}