import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dating_app/services/match_service.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/models/message_model.dart';

final matchProvider = StateNotifierProvider<MatchNotifier, MatchState>((ref) {
  return MatchNotifier();
});

class MatchState {
  final List<Match> matches;
  final List<Message> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  MatchState({
    this.matches = const [],
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  MatchState copyWith({
    List<Match>? matches,
    List<Message>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return MatchState(
      matches: matches ?? this.matches,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error ?? this.error,
    );
  }
}

class MatchNotifier extends StateNotifier<MatchState> {
  final MatchService _matchService = MatchService();

  MatchNotifier() : super(MatchState());

  Future<void> loadMatches() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _matchService.getMatches();

      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          matches: result['data'] as List<Match>? ?? [],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String? ?? 'Failed to load matches',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred. Please try again.',
      );
    }
  }

  Future<void> loadMessages(int matchId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _matchService.getMessages(matchId);

      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          messages: result['data'] as List<Message>? ?? [],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String? ?? 'Failed to load messages',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred. Please try again.',
      );
    }
  }

  Future<bool> sendMessage(int matchId, String content) async {
    state = state.copyWith(isSending: true, error: null);

    try {
      final result = await _matchService.sendMessage(matchId, content);

      if (result['success'] == true) {
        final message = Message.fromJson(result['data'] as Map<String, dynamic>);
        final updatedMessages = List<Message>.from(state.messages)..add(message);
        state = state.copyWith(
          isSending: false,
          messages: updatedMessages,
        );
        return true;
      } else {
        state = state.copyWith(
          isSending: false,
          error: result['message'] as String? ?? 'Failed to send message',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: 'An error occurred. Please try again.',
      );
      return false;
    }
  }

  Future<bool> deleteMessage(int messageId) async {
    try {
      final result = await _matchService.deleteMessage(messageId);

      if (result['success'] == true) {
        final updatedMessages = List<Message>.from(state.messages)
          ..removeWhere((m) => m.id == messageId);
        state = state.copyWith(messages: updatedMessages);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> blockMatch(int matchId) async {
    try {
      final result = await _matchService.blockMatch(matchId);

      if (result['success'] == true) {
        final updatedMatches = List<Match>.from(state.matches)
          ..removeWhere((m) => m.id == matchId);
        state = state.copyWith(matches: updatedMatches);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unmatch(int matchId) async {
    try {
      final result = await _matchService.unmatch(matchId);

      if (result['success'] == true) {
        final updatedMatches = List<Match>.from(state.matches)
          ..removeWhere((m) => m.id == matchId);
        state = state.copyWith(matches: updatedMatches);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }
}