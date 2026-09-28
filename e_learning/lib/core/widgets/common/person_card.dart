import 'package:e_learning/core/colors/colors.dart';
import 'package:flutter/material.dart';

import 'app_card.dart';
import 'match_ring.dart';
import 'pill.dart';
import 'user_avatar.dart';

class PersonCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final double rating;
  final int exchanges;
  final int? percent;
  final List<String> canTeach;
  final List<String> wantsToLearn;
  final List<Widget> actions;
  final bool isVerified;
  final bool isPro;
  final bool isOnline;
  final bool? bookmarked;
  final VoidCallback? onBookmark;

  const PersonCard({
    super.key,
    required this.name,
    this.subtitle,
    required this.rating,
    required this.exchanges,
    this.percent,
    required this.canTeach,
    required this.wantsToLearn,
    this.actions = const [],
    this.isVerified = false,
    this.isPro = false,
    this.isOnline = false,
    this.bookmarked,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(name: name, size: 46),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: c.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary),
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified_rounded, size: 16, color: c.primary),
                        ],
                        if (isPro) ...[
                          const SizedBox(width: 6),
                          Pill(text: 'PRO', color: c.tertiaryDark, background: c.tertiaryLight),
                        ],
                      ],
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
                      ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 15, color: c.tertiary),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '$exchanges exchanges',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: c.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (percent != null) ...[
                const SizedBox(width: 8),
                MatchRing(percent: percent!, size: 48),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SkillBox(label: 'Can teach', skills: canTeach, color: c.primaryDark, background: c.primaryLight),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SkillBox(label: 'Wants to learn', skills: wantsToLearn, color: c.secondaryDark, background: c.secondaryLight),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: actions[i]),
                ],
                if (onBookmark != null) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: onBookmark,
                    icon: Icon(bookmarked == true ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillBox extends StatelessWidget {
  final String label;
  final List<String> skills;
  final Color color;
  final Color background;

  const _SkillBox({required this.label, required this.skills, required this.color, required this.background});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            skills.isEmpty ? '—' : skills.take(3).join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}