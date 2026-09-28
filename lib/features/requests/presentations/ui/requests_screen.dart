import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/utils/responsive.dart';
import 'package:e_learning/features/requests/data/repo/request_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/common/empaty_state.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../cubit/requests_cubit.dart';
import '../cubit/requests_states.dart';
import 'request_widgets.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RequestCubit(getIt<RequestRepo>(), getIt<AcceptRequestUsecase>(), getIt<FirebaseAuth>()),
      child: const _RequestsView(),
    );
  }
}

class _RequestsView extends StatelessWidget {
  const _RequestsView();

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: const MyColors().background,
      appBar: AppBar(title: const Text('Requests')),
      body: ResponsiveCenter(
        maxWidth: 760,
        child: BlocBuilder<RequestCubit, RequestState>(
          builder: (context, state) {
            if (state.isLoading) return const Center(child: CircularProgressIndicator());

            final items = state.showIncoming ? state.incoming : state.outgoing;

            return ListView(
              padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
              children: [
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text('Incoming (${state.incoming.length})')),
                    ButtonSegment(value: false, label: Text('Outgoing (${state.outgoing.length})')),
                  ],
                  selected: {state.showIncoming},
                  onSelectionChanged: (selection) => context.read<RequestCubit>().setTab(selection.first),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  EmptyState(
                    icon: Icons.inbox_outlined,
                    title: state.showIncoming ? 'No incoming requests' : 'No outgoing requests',
                    subtitle: 'Exchange requests will show up here',
                  )
                else
                  for (final request in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: state.showIncoming
                          ? IncomingRequestCard(request: request)
                          : OutgoingRequestCard(request: request),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}