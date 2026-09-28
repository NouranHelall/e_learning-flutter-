import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/utils/responsive.dart';
import 'package:e_learning/core/widgets/common/chips_row.dart';
import 'package:e_learning/core/widgets/common/person_card.dart';
import 'package:e_learning/core/widgets/common/responsive_grid.dart';
import 'package:e_learning/core/widgets/common/section_header.dart';
import 'package:e_learning/features/matching/presentation/ui/match_details_sheet.dart';
import 'package:e_learning/features/profile/data/models/user_skill_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/common/empaty_state.dart';
import '../../../matching/presentation/ui/requset_sheet.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';

const List<SkillLevel?> _levels = [
  null,
  SkillLevel.beginner,
  SkillLevel.intermediate,
  SkillLevel.advanced,
  SkillLevel.expert,
];

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const MyColors().background,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 1100,
          child: BlocBuilder<ExploreCubit, ExploreState>(
            builder: (context, state) => _ExploreList(state: state),
          ),
        ),
      ),
    );
  }
}

class _ExploreList extends StatelessWidget {
  final ExploreState state;

  const _ExploreList({required this.state});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final cubit = context.read<ExploreCubit>();
    final padding = Responsive.horizontalPadding(context);
    final results = state.results;
    final quick = state.quickSkills;

    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 16, padding, 24),
      children: [
        Text('Explore', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: c.textPrimary)),
        const SizedBox(height: 4),
        Text('Find mentors and peers to swap skills with', style: TextStyle(fontSize: 14, color: c.textSecondary)),
        const SizedBox(height: 16),
        const _SearchBar(),
        const SizedBox(height: 12),
        if (quick.isNotEmpty) ...[
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Center(
                  child: Text(
                    'QUICK',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: c.textSecondary),
                  ),
                ),
                const SizedBox(width: 10),
                for (final skill in quick)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(skill),
                      onPressed: () => cubit.setQuery(skill),
                      backgroundColor: c.primaryLight,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      labelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.primaryDark),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: ChipsRow(
                labels: const ['All Levels', 'Beginner', 'Intermediate', 'Advanced', 'Expert'],
                selected: state.level == null ? 0 : _levels.indexOf(state.level),
                onSelected: (index) => cubit.setLevel(_levels[index]),
              ),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Top rated'),
              selected: state.topRated,
              showCheckmark: false,
              avatar: Icon(Icons.star_rounded, size: 16, color: c.tertiary),
              onSelected: (_) => cubit.toggleTopRated(),
              backgroundColor: c.card,
              selectedColor: c.tertiaryLight,
              shape: const StadiumBorder(),
              side: BorderSide(color: state.topRated ? c.tertiary : c.border),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SectionHeader(title: 'Mentors & Peers', badge: '${results.length} found'),
        const SizedBox(height: 10),
        if (state.isLoading)
          const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
        else if (state.error != null)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(state.error!, textAlign: TextAlign.center, style: TextStyle(color: c.error)),
          )
        else if (results.isEmpty)
            const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No results',
              subtitle: 'Try a different skill or clear the filters',
            )
          else
            ResponsiveGrid(
              children: [
                for (final match in results)
                  PersonCard(
                    name: match.user.name,
                    subtitle: match.headline,
                    rating: match.user.ratingAverage,
                    exchanges: match.user.exchangesCount,
                    percent: match.score,
                    canTeach: match.canTeach,
                    wantsToLearn: match.wantsToLearn,
                    actions: [
                      FilledButton(
                        onPressed: () => showRequestSheet(context, match),
                        child: const Text('Request Exchange'),
                      ),
                      OutlinedButton(
                        onPressed: () => showMatchDetails(context, match),
                        child: const Text('Profile'),
                      ),
                    ],
                  ),
              ],
            ),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExploreCubit, ExploreState>(
      listenWhen: (previous, current) => previous.query != current.query,
      listener: (context, state) {
        if (_controller.text != state.query) {
          _controller.value = TextEditingValue(
            text: state.query,
            selection: TextSelection.collapsed(offset: state.query.length),
          );
        }
      },
      child: TextField(
        controller: _controller,
        onChanged: context.read<ExploreCubit>().setQuery,
        decoration: InputDecoration(
          hintText: 'Search skills or people',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: BlocBuilder<ExploreCubit, ExploreState>(
            buildWhen: (previous, current) => previous.query.isEmpty != current.query.isEmpty,
            builder: (context, state) {
              if (state.query.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => context.read<ExploreCubit>().setQuery(''),
                icon: const Icon(Icons.close_rounded),
              );
            },
          ),
        ),
      ),
    );
  }
}