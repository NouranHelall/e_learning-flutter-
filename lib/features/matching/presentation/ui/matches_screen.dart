import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/utils/responsive.dart';
import 'package:e_learning/core/widgets/common/app_card.dart';
import 'package:e_learning/core/widgets/common/chips_row.dart';
import 'package:e_learning/core/widgets/common/match_ring.dart';
import 'package:e_learning/core/widgets/common/person_card.dart';
import 'package:e_learning/core/widgets/common/pill.dart';
import 'package:e_learning/core/widgets/common/responsive_grid.dart';
import 'package:e_learning/core/widgets/common/section_header.dart';
import 'package:e_learning/core/widgets/common/user_avatar.dart';
import 'package:e_learning/features/matching/data/models/match_model.dart';
import 'package:e_learning/features/matching/data/repo/match_repo.dart';
import 'package:e_learning/features/matching/presentation/cubit/match_cubit.dart';
import 'package:e_learning/features/requests/data/repo/request_repo.dart';
import 'package:e_learning/features/requests/domain/usecases/accept_request_usecase.dart';
import 'package:e_learning/features/requests/presentations/cubit/requests_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/common/empaty_state.dart';
import '../../../auth/data/user_repo.dart';
import '../../../requests/presentations/ui/request_sheet.dart';
import '../cubit/match_states.dart';
import 'match_details_sheet.dart';

class MatchesTab extends StatelessWidget {
  const MatchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const MyColors().background,
      body: const SafeArea(child: ResponsiveCenter(maxWidth: 1100, child: MatchesBody())),
    );
  }
}

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MatchCubit(getIt<MatchRepo>(), getIt<UserRepo>(), getIt<FirebaseAuth>())),
        BlocProvider(
          create: (_) => RequestCubit(getIt<RequestRepo>(), getIt<AcceptRequestUsecase>(), getIt<FirebaseAuth>()),
        ),
      ],
      child: Scaffold(
        backgroundColor: const MyColors().background,
        appBar: AppBar(title: const Text('Smart Matches')),
        body: const ResponsiveCenter(maxWidth: 1100, child: MatchesBody()),
      ),
    );
  }
}

class MatchesBody extends StatelessWidget {
  const MatchesBody({super.key});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final padding = Responsive.horizontalPadding(context);

    return BlocBuilder<MatchCubit, MatchState>(
      builder: (context, state) {
        final visible = state.visible;
        final others = visible.length > 1 ? visible.sublist(1) : <MatchModel>[];

        return ListView(
          padding: EdgeInsets.fromLTRB(padding, 12, padding, 24),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pill(
                  text: 'Reciprocal Synergy',
                  icon: Icons.bolt_rounded,
                  color: c.secondaryDark,
                  background: c.secondaryLight,
                ),
                const SizedBox(height: 10),
                Text(
                  'Your Skill Matches',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: c.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'People who can teach what you want to learn and want what you can teach.',
                  style: TextStyle(fontSize: 14, color: c.textSecondary, height: 1.35),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ChipsRow(
              labels: const ['All Matches', '90%+ Match', 'Mutual Swap'],
              selected: state.filter.index,
              onSelected: (index) => context.read<MatchCubit>().setFilter(MatchFilter.values[index]),
            ),
            const SizedBox(height: 16),
            if (state.isLoading)
              const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
            else if (state.error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.error!, textAlign: TextAlign.center, style: TextStyle(color: c.error)),
              )
            else if (visible.isEmpty)
                const EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'No matches yet',
                  subtitle: 'Add skills you want to learn in your profile to get matched',
                )
              else ...[
                  _FeaturedMatch(match: visible.first),
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SectionHeader(title: 'More Compatible Swappers', badge: '${others.length}'),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Sort by Score', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                    ),
                    const SizedBox(height: 8),
                    ResponsiveGrid(
                      children: [
                        for (final match in others)
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
                                child: const Text('Connect'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  AppCard(
                    color: c.primaryLight,
                    borderColor: Colors.transparent,
                    child: Row(
                      children: [
                        Icon(Icons.sync_alt_rounded, color: c.primary, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '100% Peer-to-Peer',
                                style: TextStyle(fontWeight: FontWeight.w800, color: c.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'No subscription fees or one-way classrooms. Just reciprocal 1-on-1 knowledge exchange.',
                                style: TextStyle(fontSize: 12.5, color: c.textSecondary, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ],
        );
      },
    );
  }
}

class _FeaturedMatch extends StatelessWidget {
  final MatchModel match;

  const _FeaturedMatch({required this.match});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final firstName = match.user.name.trim().split(' ').first;
    final theyTeach = match.theyTeachYouWant.isNotEmpty ? match.theyTeachYouWant.first : '';
    final youTeach = match.youTeachTheyWant.isNotEmpty ? match.youTeachTheyWant.first : '';
    final summary = match.isMutual
        ? '$firstName wants to learn $youTeach and you want to learn $theyTeach. A fair 1-on-1 swap.'
        : 'You want to learn $theyTeach from $firstName.';

    return AppCard(
      gradient: c.softGradient,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Pill(
                text: match.isMutual ? 'Perfect 2-Way Match' : 'Great One-Way Match',
                color: c.primaryDark,
                background: Colors.white,
              ),
              const Spacer(),
              if (match.score >= 90)
                Pill(text: 'Instant Chemistry', icon: Icons.bolt_rounded, color: c.tertiaryDark, background: c.tertiaryLight),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _Side(name: 'You', caption: youTeach.isEmpty ? 'Learner' : '$youTeach Pro')),
              MatchRing(percent: match.score, size: 66),
              Expanded(child: _Side(name: match.user.name, caption: theyTeach.isEmpty ? 'Mentor' : '$theyTeach Lead')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _TeachBox(label: 'You teach', value: youTeach.isEmpty ? '—' : youTeach)),
              const SizedBox(width: 10),
              Expanded(child: _TeachBox(label: '$firstName teaches', value: theyTeach.isEmpty ? '—' : theyTeach)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 18, color: c.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The Exchange: $summary',
                    style: TextStyle(fontSize: 13, color: c.textPrimary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => showRequestSheet(context, match),
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const Text('Start Skill Exchange'),
          ),
          TextButton(
            onPressed: () => showMatchDetails(context, match),
            child: const Text('View Full Compatibility Details'),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  final String name;
  final String caption;

  const _Side({required this.name, required this.caption});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Column(
      children: [
        UserAvatar(name: name, size: 56),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
        ),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.5, color: c.textSecondary),
        ),
      ],
    );
  }
}

class _TeachBox extends StatelessWidget {
  final String label;
  final String value;

  const _TeachBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: c.primaryDark),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}