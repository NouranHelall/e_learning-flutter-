import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_learning/features/exchanges/data/models/exchange_model.dart';
import 'package:e_learning/features/exchanges/data/repo/exchange_repo.dart';
import 'package:e_learning/features/exchanges/domain/usecase/complete_exchange_usecase.dart';

class ExchangeDetailState {
  final ExchangeModel? exchange;
  final bool isLoading;

  const ExchangeDetailState({required this.exchange, required this.isLoading});

  factory ExchangeDetailState.initial() =>
      const ExchangeDetailState(exchange: null, isLoading: true);

  ExchangeDetailState copyWith({ExchangeModel? exchange, bool? isLoading}) {
    return ExchangeDetailState(
      exchange: exchange ?? this.exchange,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

