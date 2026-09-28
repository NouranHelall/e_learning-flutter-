import 'package:e_learning/core/colors/colors.dart';
import 'package:flutter/material.dart';

class Pill extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? background;
  final IconData? icon;

  const Pill({super.key, required this.text, this.color, this.background, this.icon});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final foreground = color ?? c.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? c.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}