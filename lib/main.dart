
import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/app_route/app_route.dart';
import 'core/di/service_locator.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FirebaseService.init();
    await setupGetIt();
  } catch (error) {
    runApp(StartupError(message: error.toString()));
    return;
  }

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context) => MyApp(),
    ),
  );

  unawaited(_initNotifications());
}

Future<void> _initNotifications() async {
  try {
    await getIt<NotificationService>().init();
  } catch (error) {
    debugPrint('Notifications init failed: $error');
  }
}

class MyApp extends StatelessWidget {
  final AppRoute appRoute = AppRoute();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.light,
      navigatorKey: getIt<NotificationService>().navigatorKey,
      onGenerateRoute: appRoute.generateRoute,
    );
  }
}

class StartupError extends StatelessWidget {
  final String message;

  const StartupError({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'App failed to start',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      message,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}