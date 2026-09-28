import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/utils/date_formatter.dart';
import 'package:e_learning/core/widgets/common/app_card.dart';
import 'package:e_learning/core/widgets/common/empaty_state.dart';
import 'package:e_learning/core/widgets/common/section_header.dart';
import 'package:e_learning/core/widgets/common/user_avatar.dart';
import 'package:e_learning/features/chat/data/models/chat_message_model.dart';
import 'package:e_learning/features/chat/data/repo/chat_repo.dart';
import 'package:e_learning/features/exchanges/data/models/exchange_model.dart';
import 'package:e_learning/features/exchanges/presentation/cubit/exchange_list_cubit.dart';
import 'package:e_learning/features/exchanges/presentation/cubit/exchange_list_state.dart';
import 'package:e_learning/features/shell/presenation/cubit/nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentChatsSection extends StatelessWidget {
  const RecentChatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangeListCubit, ExchangeListState>(
      builder: (context, state) {
        final chats = state.exchanges.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Recent Chats',
              action: 'See all',
              onAction: () => context.read<NavCubit>().select(3),
            ),
            const SizedBox(height: 10),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (chats.isEmpty)
              const EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No chats yet',
                subtitle: 'Start an exchange to chat with someone',
              )
            else
              Column(
                children: [
                  for (final exchange in chats)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ChatTile(
                        exchange: exchange,
                        uid: state.currentUid,
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ExchangeModel exchange;
  final String uid;

  const _ChatTile({required this.exchange, required this.uid});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final name = exchange.otherUserName(uid);
    final width = MediaQuery.sizeOf(context).width;
    final avatar = width < 600 ? 44.0 : 48.0;

    return StreamBuilder<ChatMessageModel?>(
      stream: getIt<ChatRepo>().watchLastMessage(exchange.id),
      builder: (context, snapshot) {
        final last = snapshot.data;
        final unread =
            last != null && last.senderId != uid && !last.isReadBy(uid);

        final preview = last == null
            ? '${exchange.skillYouGive(uid)} ⇄ ${exchange.skillYouGet(uid)}'
            : last.isSession
            ? 'Session proposal · ${last.text}'
            : '${last.senderId == uid ? 'You: ' : ''}${last.text}';

        return AppCard(
          padding: const EdgeInsets.all(12),
          onTap: () => Navigator.pushNamed(
            context,
            '/chat',
            arguments: exchange.id,
          ),
          child: Row(
            children: [
              UserAvatar(name: name.isEmpty ? '?' : name, size: avatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name.isEmpty ? 'Exchange Chat' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        if (last != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            DateFormatter.ago(last.createdAt),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: unread ? c.primary : c.textSecondary,
                              fontWeight:
                              unread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: unread ? c.textPrimary : c.textSecondary,
                              fontWeight:
                              unread ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: c.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}