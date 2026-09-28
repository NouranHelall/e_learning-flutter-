import 'package:e_learning/features/chat/data/models/chat_message_model.dart';
import 'package:e_learning/features/exchanges/data/models/exchange_model.dart';

class ChatState {
  final bool isLoading;
  final List<ChatMessageModel> messages;
  final ExchangeModel? exchange;

  const ChatState({required this.isLoading, required this.messages, this.exchange});

  factory ChatState.initial() => const ChatState(isLoading: true, messages: []);

  ChatState copyWith({bool? isLoading, List<ChatMessageModel>? messages, ExchangeModel? exchange}) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      exchange: exchange ?? this.exchange,
    );
  }
}