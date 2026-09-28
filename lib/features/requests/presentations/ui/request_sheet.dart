import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/widgets/common/user_avatar.dart';
import 'package:e_learning/features/matching/data/models/match_model.dart';
import 'package:e_learning/features/requests/presentations/cubit/request_form_cubit.dart';
import 'package:e_learning/features/requests/presentations/cubit/requests_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showRequestSheet(BuildContext context, MatchModel match) {
  final requestCubit = context.read<RequestCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final wanted = match.theyTeachYouWant.isNotEmpty
      ? match.theyTeachYouWant
      : match.user.skillsKnown.map((s) => s.name).toList();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => BlocProvider(
      create: (_) => RequestFormCubit(
        offered: match.youTeachTheyWant.isNotEmpty ? match.youTeachTheyWant.first : '',
        wanted: wanted.isNotEmpty ? wanted.first : '',
      ),
      child: _RequestSheet(
        match: match,
        wantedOptions: wanted,
        onSend: (form) {
          requestCubit.sendRequest(
            toUserId: match.user.uid,
            toUserName: match.user.name,
            offeredSkill: form.offered,
            wantedSkill: form.wanted,
            message: form.message.trim(),
          );
          Navigator.pop(sheetContext);
          messenger.showSnackBar(const SnackBar(content: Text('Request sent')));
        },
      ),
    ),
  );
}

class _RequestSheet extends StatelessWidget {
  final MatchModel match;
  final List<String> wantedOptions;
  final void Function(RequestFormState) onSend;

  const _RequestSheet({required this.match, required this.wantedOptions, required this.onSend});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: BlocBuilder<RequestFormCubit, RequestFormState>(
          builder: (context, state) {
            final cubit = context.read<RequestFormCubit>();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(name: match.user.name, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exchange with ${match.user.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.textPrimary),
                          ),
                          Text(
                            '${match.score}% match',
                            style: TextStyle(fontSize: 12.5, color: c.secondaryDark, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (match.youTeachTheyWant.isNotEmpty) ...[
                  Text('You will teach', style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final skill in match.youTeachTheyWant)
                        ChoiceChip(
                          label: Text(skill),
                          selected: state.offered == skill,
                          onSelected: (_) => cubit.setOffered(skill),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Text('You will learn', style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in wantedOptions)
                      ChoiceChip(
                        label: Text(skill),
                        selected: state.wanted == skill,
                        onSelected: (_) => cubit.setWanted(skill),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: cubit.setMessage,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Message (optional)'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.wanted.isEmpty ? null : () => onSend(state),
                    child: const Text('Send Request'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}