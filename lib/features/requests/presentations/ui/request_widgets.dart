import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/utils/date_formatter.dart';
import 'package:e_learning/core/widgets/common/app_card.dart';
import 'package:e_learning/core/widgets/common/pill.dart';
import 'package:e_learning/core/widgets/common/user_avatar.dart';
import 'package:e_learning/features/requests/data/models/skill_request_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/requests_cubit.dart';

Pill _statusPill(RequestStatus status) {
  const c = MyColors();

  switch (status) {
    case RequestStatus.pending:
      return Pill(text: 'New Proposal', color: c.tertiaryDark, background: c.tertiaryLight);
    case RequestStatus.accepted:
      return Pill(text: 'Accepted', color: c.secondaryDark, background: c.secondaryLight);
    case RequestStatus.rejected:
      return Pill(text: 'Declined', color: c.error, background: c.error.withValues(alpha: 0.1));
  }
}

class _SkillPair extends StatelessWidget {
  final String label;
  final String value;

  const _SkillPair({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: c.background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: c.textSecondary),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? '—' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}

class IncomingRequestCard extends StatelessWidget {
  final SkillRequestModel request;

  const IncomingRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final name = request.fromUserName.isEmpty ? 'Someone' : request.fromUserName;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: name, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
                    ),
                    Text(
                      DateFormatter.ago(request.createdAt),
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              _statusPill(request.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SkillPair(label: 'Offers', value: request.offeredSkill)),
              const SizedBox(width: 8),
              Expanded(child: _SkillPair(label: 'Wants', value: request.wantedSkill)),
            ],
          ),
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(request.message, style: TextStyle(color: c.textSecondary, height: 1.35)),
          ],
          if (request.status == RequestStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.read<RequestCubit>().rejectRequest(request.id),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final exchangeId = await context.read<RequestCubit>().acceptRequest(request);
                      navigator.pushNamed('/exchange', arguments: exchangeId);
                    },
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
          if (request.status == RequestStatus.accepted && request.exchangeId != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/exchange', arguments: request.exchangeId),
                child: const Text('Open Exchange'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OutgoingRequestCard extends StatelessWidget {
  final SkillRequestModel request;

  const OutgoingRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: request.toUserName, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To ${request.toUserName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
                    ),
                    Text(
                      DateFormatter.ago(request.createdAt),
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              _statusPill(request.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SkillPair(label: 'You offer', value: request.offeredSkill)),
              const SizedBox(width: 8),
              Expanded(child: _SkillPair(label: 'You learn', value: request.wantedSkill)),
            ],
          ),
          if (request.status == RequestStatus.accepted && request.exchangeId != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/exchange', arguments: request.exchangeId),
                child: const Text('Open Exchange'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}