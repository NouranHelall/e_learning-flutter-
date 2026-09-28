import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/utils/responsive.dart';
import 'package:e_learning/core/widgets/common/app_card.dart';
import 'package:e_learning/core/widgets/common/user_avatar.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_state.dart';
import 'package:e_learning/features/reviews/data/repo/review_repo.dart';
import 'package:e_learning/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/common/empaty_state.dart';
import 'profile_dialogs.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewsCubit(getIt<ReviewRepo>(), getIt<FirebaseAuth>()),
      child: Scaffold(
        backgroundColor: const MyColors().background,
        body: const SafeArea(child: ResponsiveCenter(maxWidth: 760, child: _ProfileView())),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final padding = Responsive.horizontalPadding(context);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());

        final user = state.user;
        if (user == null) {
          return EmptyState(
            icon: Icons.person_off_outlined,
            title: 'Could not load profile',
            subtitle: state.error ?? 'Please try again',
          );
        }

        final cubit = context.read<ProfileCubit>();
        final goal = user.learningGoal;

        return ListView(
          padding: EdgeInsets.fromLTRB(padding, 16, padding, 24),
          children: [
            AppCard(
              gradient: c.heroGradient,
              borderColor: Colors.transparent,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      UserAvatar(name: user.name, size: 64, light: true),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => showBioEditor(context, user.bio),
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      ),
                    ],
                  ),
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(user.bio, style: const TextStyle(color: Colors.white, height: 1.4)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _Stat(value: user.ratingAverage.toStringAsFixed(1), label: 'Rating', icon: Icons.star_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _Stat(value: '${user.exchangesCount}', label: 'Exchanges', icon: Icons.swap_horiz_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _Stat(value: '${user.peopleHelped}', label: 'Helped', icon: Icons.favorite_rounded)),
              ],
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Learning Goal',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.textPrimary),
                        ),
                      ),
                      IconButton(
                        onPressed: () => showGoalEditor(context, goal),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                      ),
                    ],
                  ),
                  if (goal.isSet) ...[
                    Text(goal.title, style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: goal.progress / 100,
                        minHeight: 8,
                        backgroundColor: c.primaryLight,
                        color: c.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${goal.progress}% completed', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => showProgressSheet(context, goal),
                      child: const Text('Update Progress'),
                    ),
                  ] else
                    Text('No goal set yet', style: TextStyle(color: c.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SkillsHeader(title: 'I Can Teach', onAdd: () => showAddSkillSheet(context)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final skill in user.skillsKnown)
                  InputChip(
                    label: Text('${skill.name} · ${skill.level.name}'),
                    onDeleted: () => cubit.removeKnownSkill(skill.name),
                    backgroundColor: c.primaryLight,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    labelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.primaryDark),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _SkillsHeader(title: 'I Want to Learn', onAdd: () => showAddSkillSheet(context, teach: false)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final skill in user.skillsWanted)
                  InputChip(
                    label: Text(skill),
                    onDeleted: () => cubit.removeWantedSkill(skill),
                    backgroundColor: c.tertiaryLight,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    labelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.tertiaryDark),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _LinkTile(icon: Icons.notifications_none_rounded, label: 'Notifications', route: '/notifications'),
                  Divider(height: 1, color: c.border),
                  _LinkTile(icon: Icons.inbox_outlined, label: 'Requests', route: '/requests'),
                  Divider(height: 1, color: c.border),
                  _LinkTile(icon: Icons.campaign_outlined, label: 'Skill Board', route: '/skill_posts'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Reviews', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.textPrimary)),
            const SizedBox(height: 8),
            BlocBuilder<ReviewsCubit, ReviewsState>(
              builder: (context, reviewsState) {
                if (reviewsState.reviews.isEmpty) {
                  return Text('No reviews yet', style: TextStyle(color: c.textSecondary));
                }

                return Column(
                  children: [
                    for (final review in reviewsState.reviews)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      review.fromUserName.isEmpty ? 'Anonymous' : review.fromUserName,
                                      style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
                                    ),
                                  ),
                                  Icon(Icons.star_rounded, size: 18, color: c.tertiary),
                                  const SizedBox(width: 2),
                                  Text(review.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                              if (review.comment.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(review.comment, style: TextStyle(color: c.textSecondary, height: 1.35)),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.read<AuthCubit>().signOut(),
              style: OutlinedButton.styleFrom(foregroundColor: c.error),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _Stat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 20, color: c.primary),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
          Text(label, style: TextStyle(fontSize: 12, color: c.textSecondary)),
        ],
      ),
    );
  }
}

class _SkillsHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const _SkillsHeader({required this.title, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Row(
      children: [
        Expanded(
          child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.textPrimary)),
        ),
        IconButton(onPressed: onAdd, icon: Icon(Icons.add_circle_outline_rounded, color: c.primary)),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _LinkTile({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const MyColors().primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}