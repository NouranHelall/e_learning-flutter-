import 'dart:async';

import 'package:e_learning/features/chat/data/models/chat_message_model.dart';
import 'package:e_learning/features/chat/data/repo/chat_repo.dart';
import 'package:e_learning/features/exchanges/data/repo/exchange_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;
  final ExchangeRepo _exchangeRepo;
  final FirebaseAuth _auth;
  final String exchangeId;

  final Set<String> _marked = {};
  StreamSubscription? _messagesSub;
  StreamSubscription? _exchangeSub;

  ChatCubit(this._chatRepo, this._exchangeRepo, this._auth, this.exchangeId) : super(ChatState.initial()) {
    _messagesSub = _chatRepo.watchMessages(exchangeId).listen(
          (messages) {
        emit(state.copyWith(isLoading: false, messages: messages));
        _markRead(messages);
      },
      onError: (_) => emit(state.copyWith(isLoading: false)),
    );

    _exchangeSub = _exchangeRepo.watchExchange(exchangeId).listen(
          (exchange) => emit(state.copyWith(exchange: exchange)),
      onError: (_) {},
    );
  }

  Future<void> _markRead(List<ChatMessageModel> messages) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ids = messages
        .where((m) => m.senderId != uid && !m.readBy.contains(uid) && !_marked.contains(m.id))
        .map((m) => m.id)
        .toList();
    if (ids.isEmpty) return;

    _marked.addAll(ids);
    try {
      await _chatRepo.markRead(exchangeId: exchangeId, uid: uid, messageIds: ids);
    } catch (_) {
      _marked.removeAll(ids);
    }
  }

  Future<bool> sendMessage(String text) async {
    final user = _auth.currentUser;
    final clean = text.trim();
    if (user == null || clean.isEmpty) return false;

    try {
      await _chatRepo.sendMessage(
        exchangeId: exchangeId,
        senderId: user.uid,
        senderName: user.displayName ?? 'SkillSwap User',
        text: clean,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> proposeSession(DateTime date) async {
    final user = _auth.currentUser;
    final exchange = state.exchange;
    if (user == null || exchange == null) return false;

    final give = exchange.skillYouGive(user.uid);
    final get = exchange.skillYouGet(user.uid);
    final title = give.isEmpty || get.isEmpty ? 'Skill swap session' : '$give & $get session';

    try {
      await _chatRepo.sendSessionProposal(
        exchangeId: exchangeId,
        senderId: user.uid,
        senderName: user.displayName ?? 'SkillSwap User',
        title: title,
        sessionDate: date,
        durationMinutes: exchange.durationMinutes,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> respondToProposal(ChatMessageModel message, bool accept) async {
    final exchange = state.exchange;
    final date = message.sessionDate;
    if (exchange == null) return false;

    try {
      if (accept && date != null) {
        await _exchangeRepo.updateSchedule(
          exchangeId: exchangeId,
          sessionDate: date,
          durationMinutes: message.durationMinutes,
          mode: exchange.mode,
        );
      }
      await _chatRepo.updateProposalStatus(
        exchangeId: exchangeId,
        messageId: message.id,
        status: accept ? SessionProposalStatus.accepted : SessionProposalStatus.declined,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reschedule(ChatMessageModel message, DateTime date) async {
    final declined = await respondToProposal(message, false);
    if (!declined) return false;
    return proposeSession(date);
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    _exchangeSub?.cancel();
    return super.close();
  }
}