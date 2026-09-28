import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/services/notification_service.dart';
import 'package:e_learning/features/auth/data/user_repo.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/exchanges/data/repo/exchange_repo.dart';
import 'package:e_learning/features/exchanges/presentation/cubit/exchange_list_cubit.dart';
import 'package:e_learning/features/exchanges/presentation/ui/exchanges_tab.dart';
import 'package:e_learning/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:e_learning/features/explore/presentation/ui/explore_tab.dart';
import 'package:e_learning/features/home/presentation/ui/home_screen.dart';
import 'package:e_learning/features/matching/data/repo/match_repo.dart';
import 'package:e_learning/features/matching/presentation/cubit/match_cubit.dart';
import 'package:e_learning/features/matching/presentation/ui/matches_screen.dart';
import 'package:e_learning/features/notifications/data/repo/notification_repo.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_learning/features/profile/presentation/ui/profile_screen.dart';
import 'package:e_learning/features/requests/data/repo/request_repo.dart';
import 'package:e_learning/features/requests/domain/usecases/accept_request_usecase.dart';
import 'package:e_learning/features/requests/presentations/cubit/requests_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/nav_cubit.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavCubit()),
        BlocProvider(create: (_) => AuthCubit(getIt<FirebaseAuth>(), getIt<NotificationService>())),
        BlocProvider(create: (_) => ProfileCubit(getIt<UserRepo>(), getIt<FirebaseAuth>())),
        BlocProvider(create: (_) => MatchCubit(getIt<MatchRepo>(), getIt<UserRepo>(), getIt<FirebaseAuth>())),
        BlocProvider(
          create: (_) => RequestCubit(getIt<RequestRepo>(), getIt<AcceptRequestUsecase>(), getIt<FirebaseAuth>()),
        ),
        BlocProvider(create: (_) => ExchangeListCubit(getIt<ExchangeRepo>(), getIt<FirebaseAuth>())),
        BlocProvider(create: (_) => NotificationCubit(getIt<NotificationRepo>(), getIt<FirebaseAuth>())),
        BlocProvider(create: (_) => ExploreCubit(getIt<UserRepo>(), getIt<FirebaseAuth>())),
      ],
      child: const _ShellView(),
    );
  }
}

const _tabs = [
  (Icons.home_outlined, Icons.home_rounded, 'Home'),
  (Icons.explore_outlined, Icons.explore_rounded, 'Explore'),
  (Icons.people_outline_rounded, Icons.people_rounded, 'Matches'),
  (Icons.swap_horiz_outlined, Icons.swap_horiz_rounded, 'Exchanges'),
  (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
];

class _ShellView extends StatelessWidget {
  const _ShellView();

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.signedOut) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        }
      },
      child: BlocBuilder<NavCubit, int>(
        builder: (context, index) {
          final wide = MediaQuery.sizeOf(context).width >= 800;
          final body = IndexedStack(
            index: index,
            children: const [HomeTab(), ExploreTab(), MatchesTab(), ExchangesTab(), ProfileTab()],
          );

          if (wide) {
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: index,
                    onDestinationSelected: (value) => context.read<NavCubit>().select(value),
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: c.card,
                    indicatorColor: c.primaryLight,
                    destinations: [
                      for (var i = 0; i < _tabs.length; i++)
                        NavigationRailDestination(
                          icon: _TabIcon(icon: _tabs[i].$1, dot: i == 2),
                          selectedIcon: _TabIcon(icon: _tabs[i].$2, dot: i == 2),
                          label: Text(_tabs[i].$3),
                        ),
                    ],
                  ),
                  VerticalDivider(width: 1, color: c.border),
                  Expanded(child: body),
                ],
              ),
            );
          }

          return Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => context.read<NavCubit>().select(value),
              destinations: [
                for (var i = 0; i < _tabs.length; i++)
                  NavigationDestination(
                    icon: _TabIcon(icon: _tabs[i].$1, dot: i == 2),
                    selectedIcon: _TabIcon(icon: _tabs[i].$2, dot: i == 2),
                    label: _tabs[i].$3,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  final IconData icon;
  final bool dot;

  const _TabIcon({required this.icon, required this.dot});

  @override
  Widget build(BuildContext context) {
    final visible = dot && context.select<MatchCubit, bool>((cubit) => cubit.state.matches.any((match) => match.isMutual));

    return Badge(
      smallSize: 8,
      backgroundColor: const MyColors().secondary,
      isLabelVisible: visible,
      child: Icon(icon),
    );
  }
}