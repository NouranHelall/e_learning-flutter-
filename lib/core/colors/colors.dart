import 'package:flutter/material.dart';

class MyColors {
  const MyColors();

  final Color primary = const Color(0xFF6366F1);
  final Color primaryDark = const Color(0xFF4338CA);
  final Color primaryLight = const Color(0xFFE0E1FB);
  final Color secondary = const Color(0xFF10B981);
  final Color secondaryDark = const Color(0xFF047857);
  final Color secondaryLight = const Color(0xFFD1FAE5);
  final Color tertiary = const Color(0xFFF59E0B);
  final Color tertiaryDark = const Color(0xFFB45309);
  final Color tertiaryLight = const Color(0xFFFEF3C7);
  final Color neutral = const Color(0xFF64748B);
  final Color button = const Color(0xFF6366F1);
  final Color background = const Color(0xFFF6F6FE);
  final Color card = const Color(0xFFFFFFFF);
  final Color border = const Color(0xFFE7E8F5);
  final Color textPrimary = const Color(0xFF1E1B2E);
  final Color textSecondary = const Color(0xFF64748B);
  final Color success = const Color(0xFF10B981);
  final Color warning = const Color(0xFFF59E0B);
  final Color error = const Color(0xFFEF4444);

  LinearGradient get heroGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
  );

  LinearGradient get softGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0E1FB), Color(0xFFD1FAE5)],
  );
}