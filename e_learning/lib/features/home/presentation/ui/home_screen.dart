import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/utils/responsive.dart';
import 'package:flutter/material.dart';

import '../../../chat/presentation/ui/recentchats.dart';
import 'widgets/active_track_section.dart';
import 'widgets/greeting_section.dart';
import 'widgets/home_header.dart';
import 'widgets/skills_section.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final padding = width < 600
        ? 16.0
        : width < 900
        ? 24.0
        : Responsive.horizontalPadding(context);

    final sectionSpacing = width < 600 ? 18.0 : 22.0;

    return Scaffold(
      backgroundColor: const MyColors().background,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 1100,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              padding,
              width < 600 ? 10 : 16,
              padding,
              width < 600 ? 20 : 28,
            ),
            children: [
              const HomeHeader(),
              SizedBox(height: width < 600 ? 14 : 18),
              const GreetingSection(),
              SizedBox(height: width < 600 ? 14 : 16),
              const ActiveTrackSection(),
              SizedBox(height: sectionSpacing),
              const SkillsSection(),
              SizedBox(height: sectionSpacing),
              const RecentChatsSection(),
            ],
          ),
        ),
      ),
    );
  }
}