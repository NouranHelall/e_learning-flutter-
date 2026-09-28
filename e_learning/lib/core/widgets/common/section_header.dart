import 'package:e_learning/core/colors/colors.dart';
import 'package:flutter/material.dart';

import 'pill.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.badge, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.textPrimary),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Pill(text: badge!, color: c.secondaryDark, background: c.secondaryLight),
              ],
            ],
          ),
        ),
        if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}