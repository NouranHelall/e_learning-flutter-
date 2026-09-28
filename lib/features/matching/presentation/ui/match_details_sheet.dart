import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/widgets/common/match_ring.dart';
import 'package:e_learning/core/widgets/common/pill.dart';
import 'package:e_learning/core/widgets/common/user_avatar.dart';
import 'package:e_learning/features/matching/data/models/match_model.dart';
import 'package:e_learning/features/profile/data/models/user_skill_model.dart';
import 'package:flutter/material.dart';

Future<void> showMatchDetails(BuildContext context, MatchModel match) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _MatchDetails(match: match),
  );
}

class _MatchDetails extends StatelessWidget {
  final MatchModel match;

  const _MatchDetails({required this.match});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final user = match.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: user.name, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: c.tertiary),
                        const SizedBox(width: 3),
                        Text(
                          '${user.ratingAverage.toStringAsFixed(1)} · ${user.exchangesCount} exchanges',
                          style: TextStyle(fontSize: 12.5, color: c.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MatchRing(percent: match.score, size: 56),
            ],
          ),
          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(user.bio, style: TextStyle(color: c.textSecondary, height: 1.4)),
          ],
          const SizedBox(height: 18),
          _Group(
            title: 'They can teach you',
            items: match.theyTeachYouWant,
            color: c.secondaryDark,
            background: c.secondaryLight,
          ),
          _Group(
            title: 'You can teach them',
            items: match.youTeachTheyWant,
            color: c.primaryDark,
            background: c.primaryLight,
          ),
          _Group(
            title: 'Skills they know',
            items: user.skillsKnown.map((s) => '${s.name} · ${s.level.label}').toList(),
            color: c.primaryDark,
            background: c.primaryLight,
          ),
          _Group(
            title: 'Wants to learn',
            items: user.skillsWanted,
            color: c.tertiaryDark,
            background: c.tertiaryLight,
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final Color background;

  const _Group({required this.title, required this.items, required this.color, required this.background});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final item in items) Pill(text: item, color: color, background: background)],
          ),
        ],
      ),
    );
  }
}