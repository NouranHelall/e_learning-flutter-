import 'package:e_learning/features/notifications/data/models/notification_model.dart';

class NotificationState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final String? error;

  const NotificationState({
    required this.isLoading,
    required this.notifications,
    this.error,
  });

  factory NotificationState.initial() {
    return const NotificationState(
      isLoading: true,
      notifications: [],
    );
  }

  int get unreadCount =>
      notifications.where((item) => !item.isRead).length;

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    String? error,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      error: error,
    );
  }
}