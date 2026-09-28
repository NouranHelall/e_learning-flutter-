import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/utils/date_formatter.dart';
import 'package:e_learning/core/widgets/common/app_card.dart';
import 'package:e_learning/core/widgets/common/responsive_grid.dart';
import 'package:e_learning/core/widgets/common/section_header.dart';
import 'package:e_learning/features/exchanges/presentation/cubit/exchange_list_cubit.dart';
import 'package:e_learning/features/exchanges/presentation/cubit/exchange_list_state.dart';
import 'package:e_learning/features/shell/presenation/cubit/nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SessionsSection extends StatelessWidget {
  const SessionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return BlocBuilder<ExchangeListCubit, ExchangeListState>(
      builder: (context, state) {
        final upcoming = state.upcoming.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Upcoming Sessions',
              action: 'All exchanges',
              onAction: () => context.read<NavCubit>().select(3),
            ),
            const SizedBox(height: 10),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (upcoming.isEmpty)
              Text(
                'No upcoming sessions',
                style: TextStyle(color: c.textSecondary),
              )
            else
              ResponsiveGrid(
                children: [
                  for (final exchange in upcoming)
                    AppCard(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/exchange',
                        arguments: exchange.id,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: c.primaryLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: c.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormatter.startsIn(
                                        exchange.sessionDate!,
                                      ).toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                        color: c.secondaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      exchange.skillYouGet(
                                        state.currentUid,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: c.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'With ${exchange.otherUserName(state.currentUid)} · ${DateFormatter.dayTime(exchange.sessionDate!)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/exchange',
                                arguments: exchange.id,
                              ),
                              child: const Text('View Session'),
                            ),
                          ),
                        ],
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