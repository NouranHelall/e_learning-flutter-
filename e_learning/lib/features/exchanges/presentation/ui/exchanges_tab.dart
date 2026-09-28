import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/utils/date_formatter.dart';
import 'package:e_learning/core/utils/responsive.dart';
import 'package:e_learning/core/widgets/common/app_card.dart';
import 'package:e_learning/core/widgets/common/pill.dart';
import 'package:e_learning/core/widgets/common/responsive_grid.dart';
import 'package:e_learning/core/widgets/common/user_avatar.dart';
import 'package:e_learning/features/exchanges/data/models/exchange_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/common/empaty_state.dart';
import '../cubit/exchange_list_cubit.dart';
import '../cubit/exchange_list_state.dart';

class ExchangesTab extends StatelessWidget {
  const ExchangesTab({super.key});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 1100,
          child: BlocBuilder<ExchangeListCubit, ExchangeListState>(
            builder: (context, state) {
              final items = state.visible;

              return ListView(
                padding: EdgeInsets.fromLTRB(padding, 16, padding, 24),
                children: [
                  Text('Exchanges', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: c.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Your skill swaps and sessions', style: TextStyle(fontSize: 14, color: c.textSecondary)),
                  const SizedBox(height: 16),
                  SegmentedButton<ExchangeFilter>(
                    segments: const [
                      ButtonSegment(value: ExchangeFilter.active, label: Text('Active'), icon: Icon(Icons.bolt_rounded)),
                      ButtonSegment(
                        value: ExchangeFilter.completed,
                        label: Text('Completed'),
                        icon: Icon(Icons.check_circle_outline_rounded),
                      ),
                    ],
                    selected: {state.filter},
                    onSelectionChanged: (selection) => context.read<ExchangeListCubit>().setFilter(selection.first),
                  ),
                  const SizedBox(height: 16),
                  if (state.isLoading)
                    const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
                  else if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(state.error!, textAlign: TextAlign.center, style: TextStyle(color: c.error)),
                    )
                  else if (items.isEmpty)
                      EmptyState(
                        icon: Icons.swap_horiz_rounded,
                        title: state.filter == ExchangeFilter.active ? 'No active exchanges' : 'No completed exchanges',
                        subtitle: 'Accept a request or send one from your matches',
                      )
                    else
                      ResponsiveGrid(
                        children: [for (final exchange in items) _ExchangeCard(exchange: exchange, uid: state.currentUid)],
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ExchangeCard extends StatelessWidget {
  final ExchangeModel exchange;
  final String uid;

  const _ExchangeCard({required this.exchange, required this.uid});

  Pill _status() {
    const c = MyColors();

    switch (exchange.status) {
      case ExchangeStatus.completed:
        return Pill(text: 'Completed', color: c.secondaryDark, background: c.secondaryLight);
      case ExchangeStatus.cancelled:
        return Pill(text: 'Cancelled', color: c.error, background: c.error.withValues(alpha: 0.1));
      case ExchangeStatus.scheduled:
        return exchange.sessionDate == null
            ? Pill(text: 'Not scheduled', color: c.tertiaryDark, background: c.tertiaryLight)
            : Pill(text: 'Scheduled', color: c.primaryDark, background: c.primaryLight);
    }
  }

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final date = exchange.sessionDate;

    return AppCard(
      onTap: () => Navigator.pushNamed(context, '/exchange', arguments: exchange.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: exchange.otherUserName(uid), size: 44),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exchange.otherUserName(uid),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
                    ),
                    Text(
                      date == null ? 'No session yet' : DateFormatter.dayTime(date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              _status(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SkillTile(label: 'You teach', value: exchange.skillYouGive(uid), color: c.primaryDark, background: c.primaryLight),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.swap_horiz_rounded, color: c.textSecondary),
              ),
              Expanded(
                child: _SkillTile(label: 'You learn', value: exchange.skillYouGet(uid), color: c.secondaryDark, background: c.secondaryLight),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/chat', arguments: exchange.id),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/exchange', arguments: exchange.id),
                  child: const Text('Open'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color background;

  const _SkillTile({required this.label, required this.value, required this.color, required this.background});

  @override
  Widget build(BuildContext context) {
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}