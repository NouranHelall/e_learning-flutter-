import 'package:flutter_bloc/flutter_bloc.dart';

class RequestFormState {
  final String offered;
  final String wanted;
  final String message;

  const RequestFormState({required this.offered, required this.wanted, required this.message});

  RequestFormState copyWith({String? offered, String? wanted, String? message}) {
    return RequestFormState(
      offered: offered ?? this.offered,
      wanted: wanted ?? this.wanted,
      message: message ?? this.message,
    );
  }
}

class RequestFormCubit extends Cubit<RequestFormState> {
  RequestFormCubit({required String offered, required String wanted})
      : super(RequestFormState(offered: offered, wanted: wanted, message: ''));

  void setOffered(String value) => emit(state.copyWith(offered: value));

  void setWanted(String value) => emit(state.copyWith(wanted: value));

  void setMessage(String value) => emit(state.copyWith(message: value));
}