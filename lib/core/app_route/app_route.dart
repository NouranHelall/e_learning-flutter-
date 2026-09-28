
import 'package:flutter/material.dart';

import '../../features/chat/presentation/ui/chat_screen.dart';
import '../../features/exchanges/presentation/ui/exchange_detail_screen.dart';
import '../../features/login/presentation/ui/login_screen.dart';
import '../../features/matching/presentation/ui/matches_screen.dart';
import '../../features/notifications/presentation/ui/notification_screen.dart';
import '../../features/register/presentation/ui/register_screen.dart';
import '../../features/requests/presentations/ui/requests_screen.dart';
import '../../features/shell/presenation/ui/main_shell.dart';
import '../../features/skill_posts/presentation/skill_swap.dart';
import '../../features/splash/splash_screen.dart';

class AppRoute {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case '/home':
        return MaterialPageRoute(
          builder: (_) => const MainShell(),
        );

      case '/skill_posts':
        return MaterialPageRoute(
          builder: (_) => const SkillSwapScreen(),
        );

      case '/matches':
        return MaterialPageRoute(
          builder: (_) => const MatchesScreen(),
        );

      case '/requests':
        return MaterialPageRoute(
          builder: (_) => const RequestsScreen(),
        );

      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      case '/exchange':
        final exchangeId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ExchangeDetailScreen(
            exchangeId: exchangeId,
          ),
        );

      case '/chat':
        final exchangeId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            exchangeId: exchangeId,
          ),
        );

      default:
        return null;
    }
  }
}