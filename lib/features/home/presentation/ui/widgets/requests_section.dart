import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/widgets/common/responsive_grid.dart';
import 'package:e_learning/core/widgets/common/section_header.dart';
import 'package:e_learning/features/requests/presentations/cubit/requests_cubit.dart';
import 'package:e_learning/features/requests/presentations/cubit/requests_states.dart';
import 'package:e_learning/features/requests/presentations/ui/request_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsSection extends StatelessWidget {
  const RequestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return BlocBuilder<RequestCubit, RequestState>(
      builder: (context, state) {
        final pending = state.pendingIncoming;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Incoming Requests',
              badge: pending.isEmpty ? null : '${pending.length} pending',
              action: 'See all',
              onAction: () =>
                  Navigator.pushNamed(context, '/requests'),
            ),
            const SizedBox(height: 10),
            if (pending.isEmpty)
              Text(
                'No pending requests',
                style: TextStyle(color: c.textSecondary),
              )
            else
              ResponsiveGrid(
                children: [
                  for (final request in pending.take(2))
                    IncomingRequestCard(
                      request: request,
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}