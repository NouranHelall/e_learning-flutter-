import 'package:e_learning/features/exchanges/data/models/exchange_model.dart';

enum ExchangeFilter { active, completed }

class ExchangeListState {
  final bool isLoading;
  final List<ExchangeModel> exchanges;
  final ExchangeFilter filter;
  final String currentUid;
  final String? error;

  const ExchangeListState({
    required this.isLoading,
    required this.exchanges,
    required this.filter,
    required this.currentUid,
    this.error,
  });

  factory ExchangeListState.initial(String uid) => ExchangeListState(
    isLoading: true,
    exchanges: const [],
    filter: ExchangeFilter.active,
    currentUid: uid,
  );

  List<ExchangeModel> get visible {
    return exchanges.where((exchange) {
      final active = exchange.status == ExchangeStatus.scheduled;
      return filter == ExchangeFilter.active ? active : !active;
    }).toList();
  }

  List<ExchangeModel> get upcoming {
    final limit = DateTime.now().subtract(const Duration(hours: 2));
    final list = exchanges.where((exchange) {
      final date = exchange.sessionDate;
      return exchange.status == ExchangeStatus.scheduled && date != null && date.isAfter(limit);
    }).toList();
    list.sort((a, b) => a.sessionDate!.compareTo(b.sessionDate!));
    return list;
  }

  ExchangeListState copyWith({
    bool? isLoading,
    List<ExchangeModel>? exchanges,
    ExchangeFilter? filter,
    String? error,
  }) {
    return ExchangeListState(
      isLoading: isLoading ?? this.isLoading,
      exchanges: exchanges ?? this.exchanges,
      filter: filter ?? this.filter,
      currentUid: currentUid,
      error: error,
    );
  }
}