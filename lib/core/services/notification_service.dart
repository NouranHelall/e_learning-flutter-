
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static const AndroidNotificationChannel _channel =
  AndroidNotificationChannel(
    'skillswap_notifications',
    'SkillSwap Notifications',
    description: 'SkillSwap app notifications',
    importance: Importance.high,
  );

  bool _initialized = false;
  String? _currentToken;
  Map<String, dynamic>? _pendingNavigationData;

  NotificationService(
      this._messaging,
      this._auth,
      this._firestore,
      );

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) return;

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    await _requestPermission();
    await _initializeLocalNotifications();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _saveToken();

    _auth.authStateChanges().listen((user) async {
      if (user == null) return;
      await _saveToken();
    });

    _messaging.onTokenRefresh.listen(_saveTokenValue);

    FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationTap,
    );

    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;

        if (payload == null || payload.isEmpty) return;

        try {
          final decoded = jsonDecode(payload);

          if (decoded is Map) {
            _navigateFromData(
              Map<String, dynamic>.from(decoded),
            );
          }
        } catch (_) {
          return;
        }
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> _saveToken() async {
    if (_auth.currentUser == null) return;

    final token = await _messaging.getToken();

    if (token == null) return;

    await _saveTokenValue(token);
  }

  Future<void> _saveTokenValue(String token) async {
    _currentToken = token;

    final uid = _auth.currentUser?.uid;

    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(token)
        .set({
      'token': token,
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unregisterDevice() async {
    final uid = _auth.currentUser?.uid;
    final token = _currentToken;

    if (uid == null || token == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(token)
        .delete();
  }

  Future<void> _handleForegroundMessage(
      RemoteMessage message,
      ) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final notification = message.notification;

    final title =
        notification?.title ?? message.data['title']?.toString();

    final body =
        notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) return;

    await _localNotifications.show(
      DateTime.now()
          .millisecondsSinceEpoch
          .remainder(2147483647),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    _navigateFromData(
      Map<String, dynamic>.from(message.data),
    );
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      _pendingNavigationData = data;
      return;
    }

    final type = data['type']?.toString();
    final exchangeId = data['exchangeId']?.toString();

    final hasExchange =
        exchangeId != null && exchangeId.isNotEmpty;

    switch (type) {
      case 'chat':
        if (hasExchange) {
          navigator.pushNamed(
            '/chat',
            arguments: exchangeId,
          );
        }
        break;

      case 'exchange':
        if (hasExchange) {
          navigator.pushNamed(
            '/exchange',
            arguments: exchangeId,
          );
        }
        break;

      case 'request':
      case 'request_accepted':
      case 'request_rejected':
        navigator.pushNamed('/requests');
        break;

      case 'match':
        navigator.pushNamed('/matches');
        break;

      default:
        navigator.pushNamed('/notifications');
        break;
    }
  }

  void handlePendingNavigation() {
    final data = _pendingNavigationData;

    if (data == null) return;

    _pendingNavigationData = null;

    _navigateFromData(data);
  }
}