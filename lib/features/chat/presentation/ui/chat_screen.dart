import 'dart:math' as math;

import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/utils/date_formatter.dart';
import 'package:e_learning/core/utils/pickers.dart';
import 'package:e_learning/core/utils/responsive.dart';
import 'package:e_learning/core/widgets/common/app_card.dart';
import 'package:e_learning/core/widgets/common/empaty_state.dart';
import 'package:e_learning/core/widgets/common/pill.dart';
import 'package:e_learning/core/widgets/common/user_avatar.dart';
import 'package:e_learning/features/chat/data/models/chat_message_model.dart';
import 'package:e_learning/features/chat/data/repo/chat_repo.dart';
import 'package:e_learning/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:e_learning/features/chat/presentation/cubit/chat_state.dart';
import 'package:e_learning/features/exchanges/data/models/exchange_model.dart';
import 'package:e_learning/features/exchanges/data/repo/exchange_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatelessWidget {
  final String exchangeId;

  const ChatScreen({super.key, required this.exchangeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(getIt<ChatRepo>(), getIt<ExchangeRepo>(), getIt<FirebaseAuth>(), exchangeId),
      child: _ChatView(exchangeId: exchangeId),
    );
  }
}

class _ChatView extends StatefulWidget {
  final String exchangeId;

  const _ChatView({required this.exchangeId});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _headerOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    final cubit = context.read<ChatCubit>();
    _controller.clear();
    final ok = await cubit.sendMessage(text);
    if (!ok && mounted) {
      _fill(text);
      _toast('Message failed to send');
    }
  }

  Future<void> _suggestTime() async {
    final cubit = context.read<ChatCubit>();
    final date = await pickDateTime(context);
    if (date == null) return;
    final ok = await cubit.proposeSession(date);
    if (!ok && mounted) _toast('Could not send the proposal');
  }

  Future<void> _accept(ChatMessageModel message) async {
    final cubit = context.read<ChatCubit>();
    final ok = await cubit.respondToProposal(message, true);
    if (!mounted) return;
    _toast(ok ? 'Session scheduled' : 'Could not accept the session');
  }

  Future<void> _reschedule(ChatMessageModel message) async {
    final cubit = context.read<ChatCubit>();
    final date = await pickDateTime(context);
    if (date == null) return;
    final ok = await cubit.reschedule(message, date);
    if (!ok && mounted) _toast('Could not send the new time');
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _fill(String text) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final uid = getIt<FirebaseAuth>().currentUser?.uid ?? '';
    final padding = Responsive.horizontalPadding(context);

    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (previous, current) => previous.messages.length != current.messages.length,
      listener: (context, state) => _scrollToEnd(),
      builder: (context, state) {
        final exchange = state.exchange;
        final otherName = exchange?.otherUserName(uid) ?? '';
        final otherId = exchange?.otherUserId(uid) ?? '';
        final canRespond = exchange?.status == ExchangeStatus.scheduled;
        final cancelled = exchange?.status == ExchangeStatus.cancelled;
        final messages = state.messages;

        final items = <Widget>[];
        for (var i = 0; i < messages.length; i++) {
          final message = messages[i];
          final previous = i == 0 ? null : messages[i - 1];
          final newDay = previous == null || !_sameDay(previous.createdAt, message.createdAt);
          if (newDay) items.add(_DayLabel(text: DateFormatter.day(message.createdAt)));

          final mine = message.senderId == uid;
          final firstOfGroup =
              previous == null || newDay || previous.senderId != message.senderId || previous.isSession;

          if (message.isSession) {
            items.add(
              _SessionCard(
                message: message,
                mine: mine,
                canRespond: canRespond,
                onAccept: () => _accept(message),
                onReschedule: () => _reschedule(message),
              ),
            );
          } else {
            items.add(
              _Bubble(
                message: message,
                mine: mine,
                read: message.isReadBy(otherId),
                showName: !mine && firstOfGroup,
                showAvatar: !mine && firstOfGroup,
                fallbackName: otherName,
              ),
            );
          }
        }
        if (items.isNotEmpty) items.add(const _ProtectionNote());

        return Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                UserAvatar(name: otherName.isEmpty ? '?' : otherName, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherName.isEmpty ? 'Exchange Chat' : otherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.textPrimary),
                      ),
                      Text('Exchange chat', style: TextStyle(fontSize: 11.5, color: c.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: ResponsiveCenter(
            maxWidth: 820,
            child: Column(
              children: [
                if (exchange != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(padding, 4, padding, 8),
                    child: _ExchangeHeader(
                      exchange: exchange,
                      uid: uid,
                      open: _headerOpen,
                      onToggle: () => setState(() => _headerOpen = !_headerOpen),
                    ),
                  ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                      ? const EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Say hello',
                    subtitle: 'Plan your session and share what you want to focus on',
                  )
                      : ListView(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(padding, 8, padding, 8),
                    children: items,
                  ),
                ),
                if (cancelled)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: c.card, border: Border(top: BorderSide(color: c.border))),
                    child: SafeArea(
                      top: false,
                      child: Text(
                        'This exchange was cancelled',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                else
                  _Composer(
                    controller: _controller,
                    onSend: _send,
                    onSuggestion: _fill,
                    onSuggestTime: _suggestTime,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExchangeHeader extends StatelessWidget {
  final ExchangeModel exchange;
  final String uid;
  final bool open;
  final VoidCallback onToggle;

  const _ExchangeHeader({
    required this.exchange,
    required this.uid,
    required this.open,
    required this.onToggle,
  });

  Pill _status() {
    const c = MyColors();
    switch (exchange.status) {
      case ExchangeStatus.completed:
        return Pill(text: 'Completed', icon: Icons.check_circle_outline_rounded, color: c.secondaryDark, background: c.secondaryLight);
      case ExchangeStatus.cancelled:
        return Pill(text: 'Cancelled', icon: Icons.block_rounded, color: c.error, background: c.error.withValues(alpha: 0.1));
      case ExchangeStatus.scheduled:
        return Pill(text: 'Active exchange', icon: Icons.bolt_rounded, color: c.secondaryDark, background: c.secondaryLight);
    }
  }

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final date = exchange.sessionDate;
    final give = exchange.skillYouGive(uid);
    final get = exchange.skillYouGet(uid);
    final modeLabel = exchange.mode == SessionMode.online ? 'Online' : 'In person';

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onToggle,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(alignment: Alignment.centerLeft, child: _status()),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              give.isEmpty ? '—' : give,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w800, color: c.textPrimary),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.swap_horiz_rounded, size: 18, color: c.textSecondary),
                          ),
                          Flexible(
                            child: Text(
                              get.isEmpty ? '—' : get,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w800, color: c.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: c.textSecondary),
              ],
            ),
            if (open) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Pill(
                    text: '$modeLabel · ${exchange.durationMinutes}m',
                    icon: Icons.videocam_outlined,
                    color: c.primaryDark,
                    background: c.primaryLight,
                  ),
                  if (date != null)
                    Pill(
                      text: DateFormatter.dayTime(date),
                      icon: Icons.event_rounded,
                      color: c.primaryDark,
                      background: c.primaryLight,
                    ),
                  if (exchange.meetLink.isNotEmpty)
                    Pill(
                      text: 'Meeting link attached',
                      icon: Icons.link_rounded,
                      color: c.secondaryDark,
                      background: c.secondaryLight,
                    ),
                  Pill(
                    text: 'Reciprocal Trade',
                    icon: Icons.handshake_outlined,
                    color: c.secondaryDark,
                    background: c.secondaryLight,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniTile(label: 'You teach', value: give, color: c.primaryDark, background: c.primaryLight),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.swap_horiz_rounded, color: c.textSecondary),
                  ),
                  Expanded(
                    child: _MiniTile(label: 'You learn', value: get, color: c.secondaryDark, background: c.secondaryLight),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/exchange', arguments: exchange.id),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                  icon: Icon(date == null ? Icons.event_available_rounded : Icons.open_in_new_rounded, size: 18),
                  label: Text(date == null ? 'Schedule Session' : 'Open Session'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color background;

  const _MiniTile({required this.label, required this.value, required this.color, required this.background});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: color),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String text;

  const _DayLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: c.primaryLight, borderRadius: BorderRadius.circular(20)),
          child: Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: c.primaryDark)),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool mine;
  final bool read;
  final bool showName;
  final bool showAvatar;
  final String fallbackName;

  const _Bubble({
    required this.message,
    required this.mine,
    required this.read,
    required this.showName,
    required this.showAvatar,
    required this.fallbackName,
  });

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final maxWidth = math.min(MediaQuery.sizeOf(context).width * 0.72, 440.0);
    final name = message.senderName.isEmpty ? fallbackName : message.senderName;

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: mine ? c.primary : c.card,
          border: mine ? null : Border.all(color: c.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.text,
                style: TextStyle(color: mine ? Colors.white : c.textPrimary, height: 1.35),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormatter.time(message.createdAt),
                  style: TextStyle(fontSize: 10.5, color: mine ? Colors.white70 : c.textSecondary),
                ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    read ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: read ? c.secondaryLight : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (mine) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: 30, child: showAvatar ? UserAvatar(name: name.isEmpty ? '?' : name, size: 28) : null),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showName && name.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3, left: 2),
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.textSecondary),
                  ),
                ),
              bubble,
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ChatMessageModel message;
  final bool mine;
  final bool canRespond;
  final VoidCallback onAccept;
  final VoidCallback onReschedule;

  const _SessionCard({
    required this.message,
    required this.mine,
    required this.canRespond,
    required this.onAccept,
    required this.onReschedule,
  });

  Pill _status() {
    const c = MyColors();
    switch (message.proposalStatus) {
      case SessionProposalStatus.accepted:
        return Pill(
          text: 'Accepted',
          icon: Icons.check_circle_outline_rounded,
          color: c.secondaryDark,
          background: c.secondaryLight,
        );
      case SessionProposalStatus.declined:
        return Pill(
          text: 'Rescheduled',
          icon: Icons.history_rounded,
          color: c.tertiaryDark,
          background: c.tertiaryLight,
        );
      case SessionProposalStatus.pending:
        return Pill(
          text: mine ? 'Proposal Sent' : 'Proposal Received',
          icon: Icons.event_note_rounded,
          color: c.primaryDark,
          background: c.primaryLight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final date = message.sessionDate;
    final maxWidth = math.min(MediaQuery.sizeOf(context).width * 0.9, 460.0);
    final pending = message.proposalStatus == SessionProposalStatus.pending;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _status(),
                    const Spacer(),
                    Text(
                      '${message.durationMinutes} mins',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.primaryDark),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  message.text,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: date == null ? '—' : DateFormatter.day(date),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.schedule_rounded,
                        label: 'Time',
                        value: date == null ? '—' : DateFormatter.time(date),
                      ),
                    ),
                  ],
                ),
                if (pending && !mine && canRespond) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Accept & Schedule'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onReschedule,
                    icon: const Icon(Icons.schedule_rounded, size: 18),
                    label: const Text('Reschedule'),
                  ),
                ],
                if (pending && mine) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Waiting for a response',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: c.primaryLight.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10.5, color: c.textSecondary)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionNote extends StatelessWidget {
  const _ProtectionNote();

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: c.primaryLight, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(Icons.verified_user_outlined, size: 16, color: c.primaryDark),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Zero-credit barter · Covered by SkillSwap Mutual Protection',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: c.primaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String> onSuggestion;
  final VoidCallback onSuggestTime;

  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onSuggestion,
    required this.onSuggestTime,
  });

  static const List<String> _suggestions = ['Suggest a time', 'Share a resource link', 'Send a reminder', 'Thank you!'];

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final padding = Responsive.horizontalPadding(context);

    return Container(
      decoration: BoxDecoration(color: c.card, border: Border(top: BorderSide(color: c.border))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ActionChip(
                      label: Text(_suggestions[index]),
                      avatar: index == 0 ? Icon(Icons.event_rounded, size: 16, color: c.primaryDark) : null,
                      onPressed: () => index == 0 ? onSuggestTime() : onSuggestion(_suggestions[index]),
                      backgroundColor: c.primaryLight,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.primaryDark),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: const InputDecoration(hintText: 'Type a message'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: onSend,
                    style: IconButton.styleFrom(backgroundColor: c.primary, minimumSize: const Size(48, 48)),
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}