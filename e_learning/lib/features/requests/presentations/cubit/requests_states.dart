import 'package:e_learning/features/requests/data/models/skill_request_model.dart';

class RequestState {
  final bool isLoading;
  final List<SkillRequestModel> incoming;
  final List<SkillRequestModel> outgoing;
  final bool showIncoming;
  final String? error;

  const RequestState({
    required this.isLoading,
    required this.incoming,
    required this.outgoing,
    required this.showIncoming,
    this.error,
  });

  factory RequestState.initial() =>
      const RequestState(isLoading: true, incoming: [], outgoing: [], showIncoming: true);

  List<SkillRequestModel> get pendingIncoming =>
      incoming.where((request) => request.status == RequestStatus.pending).toList();

  RequestState copyWith({
    bool? isLoading,
    List<SkillRequestModel>? incoming,
    List<SkillRequestModel>? outgoing,
    bool? showIncoming,
    String? error,
  }) {
    return RequestState(
      isLoading: isLoading ?? this.isLoading,
      incoming: incoming ?? this.incoming,
      outgoing: outgoing ?? this.outgoing,
      showIncoming: showIncoming ?? this.showIncoming,
      error: error,
    );
  }
}