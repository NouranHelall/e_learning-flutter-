import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/features/exchanges/data/models/exchange_model.dart';
import 'package:e_learning/features/exchanges/data/repo/exchange_repo.dart';
import 'package:e_learning/features/exchanges/domain/usecase/complete_exchange_usecase.dart';

import '../../../reviews/data/repo/review_repo.dart';
import '../../../reviews/domain/usecase/rate_exchange_usecase.dart';
import '../cubit/exchanges_cubit.dart';
import '../cubit/exchanges_states.dart';

class ExchangeDetailScreen extends StatelessWidget {
  final String exchangeId;
  const ExchangeDetailScreen({super.key, required this.exchangeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExchangeDetailCubit(
        getIt<ExchangeRepo>(),
        getIt<CompleteExchangeUsecase>(),
        getIt<RateExchangeUsecase>(),
        getIt<FirebaseAuth>(),
        exchangeId,
      ),
      child: const _ExchangeDetailView(),
    );
  }
}

class _ExchangeDetailView extends StatefulWidget {
  const _ExchangeDetailView();

  @override
  State<_ExchangeDetailView> createState() => _ExchangeDetailViewState();
}

class _ExchangeDetailViewState extends State<_ExchangeDetailView> {
  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;
  int _duration = 60;
  SessionMode _mode = SessionMode.online;
  double _rating = 5;
  final _commentController = TextEditingController();

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _pickedDate = date;
      _pickedTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = getIt<FirebaseAuth>().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: MyColors().background,
      appBar: AppBar(
        backgroundColor: MyColors().background,
        elevation: 0,
        foregroundColor: MyColors().textPrimary,
        title: const Text('Exchange Session'),
      ),
      body: BlocBuilder<ExchangeDetailCubit, ExchangeDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final exchange = state.exchange;
          if (exchange == null) {
            return const Center(child: Text('Exchange not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'With ${exchange.otherUserName(currentUid)}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('You teach: ${exchange.skillYouGive(currentUid)}'),
                      Text('You learn: ${exchange.skillYouGet(currentUid)}'),
                      const SizedBox(height: 8),
                      Text('Status: ${exchange.status.name}'),
                      IconButton(
                        icon: const Icon(Icons.chat_outlined),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/chat', arguments: exchange.id),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (exchange.status == ExchangeStatus.scheduled) ...[
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Schedule Session', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => _pickDate(context),
                          child: Text(
                            _pickedDate == null
                                ? (exchange.sessionDate == null
                                ? 'Pick date and time'
                                : exchange.sessionDate.toString())
                                : '$_pickedDate $_pickedTime',
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          initialValue: _duration,
                          decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                          items: const [30, 45, 60, 90, 120]
                              .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                              .toList(),
                          onChanged: (v) => setState(() => _duration = v ?? 60),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<SessionMode>(
                          initialValue: _mode,
                          decoration: const InputDecoration(labelText: 'Mode'),
                          items: SessionMode.values
                              .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _mode = v ?? SessionMode.online),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: MyColors().button),
                          onPressed: () {
                            if (_pickedDate == null || _pickedTime == null) return;
                            final sessionDate = DateTime(
                              _pickedDate!.year,
                              _pickedDate!.month,
                              _pickedDate!.day,
                              _pickedTime!.hour,
                              _pickedTime!.minute,
                            );
                            context.read<ExchangeDetailCubit>().schedule(
                              sessionDate: sessionDate,
                              durationMinutes: _duration,
                              mode: _mode,
                            );
                          },
                          child: const Text('Save Schedule'),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: exchange.hasCompletedBy(currentUid)
                                ? null
                                : () => context.read<ExchangeDetailCubit>().markCompleted(),
                            child: Text(
                              exchange.hasCompletedBy(currentUid)
                                  ? 'Waiting for the other person'
                                  : 'Mark as Completed',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (exchange.status == ExchangeStatus.completed)
                FutureBuilder<bool>(
                  future: getIt<ReviewRepo>().hasReviewed(
                    exchangeId: exchange.id,
                    fromUserId: currentUid,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('You already rated this exchange'),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rate this exchange', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              Row(
                                children: List.generate(5, (index) {
                                  final starValue = index + 1;
                                  return IconButton(
                                    icon: Icon(
                                      starValue <= _rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber.shade700,
                                    ),
                                    onPressed: () => setState(() => _rating = starValue.toDouble()),
                                  );
                                }),
                              ),
                              TextField(
                                controller: _commentController,
                                maxLines: 3,
                                decoration: const InputDecoration(labelText: 'Comment'),
                              ),
                              const SizedBox(height: 10),
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: MyColors().button),
                                onPressed: () {
                                  context.read<ExchangeDetailCubit>().submitRating(
                                    rating: _rating,
                                    comment: _commentController.text.trim(),
                                  );
                                  setState(() {});
                                },
                                child: const Text('Submit Rating'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}