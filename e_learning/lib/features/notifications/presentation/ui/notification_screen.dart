import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/utils/responsive.dart';
import 'package:e_learning/features/notifications/data/models/notification_model.dart';
import 'package:e_learning/features/notifications/data/repo/notification_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationCubit(
        getIt<NotificationRepo>(),
        getIt<FirebaseAuth>(),
      ),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final colors = MyColors();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        foregroundColor: colors.textPrimary,
        title: BlocBuilder<NotificationCubit, NotificationState>(
          buildWhen: (previous, current) =>
          previous.unreadCount != current.unreadCount,
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Notifications'),
                if (state.unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            buildWhen: (previous, current) =>
            previous.unreadCount != current.unreadCount,
            builder: (context, state) {
              if (state.unreadCount == 0) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: () =>
                    context.read<NotificationCubit>().markAllAsRead(),
                child: Text(
                  'Read all',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ResponsiveCenter(
        maxWidth: 760,
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.error),
                  ),
                ),
              );
            }

            final items = state.notifications;

            if (items.isEmpty) {
              return const _EmptyView();
            }

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                Responsive.horizontalPadding(context),
                16,
                Responsive.horizontalPadding(context),
                24,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _NotificationCard(
                  notification: items[index],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({
    required this.notification,
  });

  IconData _icon(String type) {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'request':
        return Icons.person_add_alt_1;
      case 'request_accepted':
        return Icons.check_circle_outline;
      case 'request_rejected':
        return Icons.cancel_outlined;
      case 'exchange':
        return Icons.swap_horiz;
      case 'match':
        return Icons.favorite_border;
      default:
        return Icons.notifications_none;
    }
  }

  Color _iconColor(String type) {
    final colors = MyColors();

    switch (type) {
      case 'request':
        return colors.tertiary;
      case 'request_accepted':
      case 'match':
        return colors.secondary;
      case 'request_rejected':
        return colors.error;
      default:
        return colors.primary;
    }
  }

  Color _iconBackground(String type) {
    final colors = MyColors();

    switch (type) {
      case 'request':
        return colors.tertiaryLight;
      case 'request_accepted':
      case 'match':
        return colors.secondaryLight;
      case 'request_rejected':
        return colors.error.withValues(alpha: 0.1);
      default:
        return colors.primaryLight;
    }
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} d ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  void _open(BuildContext context) {
    context.read<NotificationCubit>().markAsRead(notification.id);

    final exchangeId = notification.exchangeId;

    switch (notification.type) {
      case 'chat':
        if (exchangeId != null) {
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: exchangeId,
          );
        }
      case 'exchange':
        if (exchangeId != null) {
          Navigator.pushNamed(
            context,
            '/exchange',
            arguments: exchangeId,
          );
        }
      case 'request':
      case 'request_accepted':
      case 'request_rejected':
        Navigator.pushNamed(context, '/requests');
      case 'match':
        Navigator.pushNamed(context, '/matches');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = MyColors();
    final unread = !notification.isRead;

    return Material(
      color: unread ? colors.primaryLight : colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconBackground(notification.type),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon(notification.type),
                  color: _iconColor(notification.type),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        unread ? FontWeight.w700 : FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.neutral,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread)
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(
                    top: 6,
                    left: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final colors = MyColors();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 40,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'New matches, requests and messages will show up here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}