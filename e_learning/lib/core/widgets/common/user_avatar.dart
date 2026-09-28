import 'package:e_learning/core/colors/colors.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool light;

  const UserAvatar({super.key, required this.name, this.size = 44, this.light = false});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: light ? null : c.heroGradient,
        color: light ? Colors.white.withValues(alpha: 0.22) : null,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        initial,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.4),
      ),
    );
  }
}