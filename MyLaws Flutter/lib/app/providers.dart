import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/saved_conversation_service.dart';
import '../data/fixtures/demo_fixture_adapter.dart';
import '../domain/models/answer_request.dart';
import '../domain/models/answer_response.dart';
import '../domain/models/app_failure.dart';
import '../domain/models/checklist_step.dart';
import '../domain/models/draft_document.dart';
import '../domain/models/fact.dart';
import '../domain/models/pack_state.dart';
import '../domain/models/user_quota.dart';
import '../domain/repositories/answer_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/draft_repository.dart';
import '../domain/repositories/office_repository.dart';
import '../domain/repositories/pack_repository.dart';
import '../domain/repositories/quota_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/source_repository.dart';

// --- Fixture Adapter & Service Registries ---
final demoFixtureAdapterProvider = Provider<DemoFixtureAdapter>((ref) {
  return DemoFixtureAdapter();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(demoFixtureAdapterProvider);
});

final answerRepositoryProvider = Provider<AnswerRepository>((ref) {
  return ref.watch(demoFixtureAdapterProvider);
});

final sourceRepositoryProvider = Provider<SourceRepository>((ref) {
  return ref.watch(demoFixtureAdapterProvider);
});

final officeRepositoryProvider = Provider<OfficeRepository>((ref) {
  return ref.watch(demoFixtureAdapterProvider);
});

final draftRepositoryProvider = Provider<DraftRepository>((ref) {
  return ref.watch(demoFixtureAdapterProvider);
});

final packRepositoryProvider = Provider<PackRepository>((ref) {
  return ref.watch(demoFixtureAdapterProvider);
});

final quotaRepositoryProvider = Provider<QuotaRepository>((ref) {
  return ref.watch(demoFixtureAdapterProvider);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return ref.watch(demoFixtureAdapterProvider);
});

// --- Auth State ---
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// --- Quota State ---
final quotaStateProvider = StreamProvider<UserQuota>((ref) {
  return ref.watch(quotaRepositoryProvider).watchQuota();
});

// --- Pack State ---
final packStateProvider = StreamProvider<PackState>((ref) {
  return ref.watch(packRepositoryProvider).watchPackState();
});

// --- Settings State ---
class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(const UserSettings()) {
    _init();
  }

  Future<void> _init() async {
    state = await _repo.getSettings();
  }

  Future<void> update(UserSettings next) async {
    state = next;
    await _repo.updateSettings(next);
  }

  Future<void> setLocale(String lang) async {
    final next = state.copyWith(appLanguage: lang);
    await update(next);
  }

  Future<void> setTheme(AppThemeMode mode) async {
    final next = state.copyWith(themeMode: mode);
    await update(next);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

// --- Conversation State Model ---
class ChatMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String text;
  final AnswerResponse? response;
  final bool isSuperseded;
  final DateTime timestamp;
  final bool shouldAnimate;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.response,
    this.isSuperseded = false,
    required this.timestamp,
    this.shouldAnimate = false,
  });

  ChatMessage copyWith({bool? isSuperseded, bool? shouldAnimate}) {
    return ChatMessage(
      id: id,
      role: role,
      text: text,
      response: response,
      isSuperseded: isSuperseded ?? this.isSuperseded,
      timestamp: timestamp,
      shouldAnimate: shouldAnimate ?? this.shouldAnimate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'text': text,
        if (response != null) 'response': response!.toJson(),
        'isSuperseded': isSuperseded,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: json['role'] as String,
      text: json['text'] as String,
      response: json['response'] != null
          ? AnswerResponse.fromJson(json['response'] as Map<String, dynamic>)
          : null,
      isSuperseded: json['isSuperseded'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      shouldAnimate: false,
    );
  }
}

class ConversationState {
  final String caseId;
  final List<ChatMessage> messages;
  final List<Fact> facts;
  final List<ChecklistStep> checklist;
  final bool isWorking;
  final String? activeRequestId;
  final String? errorMessage;
  final String preservedInput;

  const ConversationState({
    required this.caseId,
    this.messages = const [],
    this.facts = const [],
    this.checklist = const [],
    this.isWorking = false,
    this.activeRequestId,
    this.errorMessage,
    this.preservedInput = '',
  });

  ConversationState copyWith({
    String? caseId,
    List<ChatMessage>? messages,
    List<Fact>? facts,
    List<ChecklistStep>? checklist,
    bool? isWorking,
    String? activeRequestId,
    String? errorMessage,
    String? preservedInput,
  }) {
    return ConversationState(
      caseId: caseId ?? this.caseId,
      messages: messages ?? this.messages,
      facts: facts ?? this.facts,
      checklist: checklist ?? this.checklist,
      isWorking: isWorking ?? this.isWorking,
      activeRequestId: activeRequestId,
      errorMessage: errorMessage,
      preservedInput: preservedInput ?? this.preservedInput,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  final AnswerRepository _answerRepo;
  final QuotaRepository _quotaRepo;
  final Ref? _ref;

  ConversationNotifier(this._answerRepo, this._quotaRepo, [this._ref])
      : super(ConversationState(
            caseId: 'case_${DateTime.now().millisecondsSinceEpoch}'));

  void setPreservedInput(String text) {
    state = state.copyWith(preservedInput: text);
  }

  void startNewConversation() {
    state = ConversationState(
      caseId: 'case_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  void loadSavedConversation({
    required String caseId,
    required List<ChatMessage> messages,
    List<Fact> facts = const [],
    List<ChecklistStep> checklist = const [],
  }) {
    state = ConversationState(
      caseId: caseId,
      messages: messages,
      facts: facts,
      checklist: checklist,
      isWorking: false,
      activeRequestId: null,
      errorMessage: null,
      preservedInput: '',
    );
  }

  Future<void> sendNarrative(String userText,
      {required String language}) async {
    if (userText.trim().isEmpty) return;

    // Pre-flight check: verify daily limit before sending request
    final currentQuota = await _quotaRepo.getQuota();
    if (!currentQuota.canQuery || currentQuota.remaining <= 0) {
      state = state.copyWith(
        errorMessage: language == 'bn'
            ? 'আজকের দৈনিক 30টি আইনি পরামর্শের কোটা পূর্ণ হয়েছে। আগামীকাল রাত 12:00টায় কোটা আবার নবায়ন হবে।'
            : 'Daily limit of 30 legal queries reached. Quota will renew tomorrow at 12:00 AM.',
        preservedInput: userText,
      );
      return;
    }

    final userMsg = ChatMessage(
      id: 'turn_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      text: userText.trim(),
      timestamp: DateTime.now(),
    );

    final reqId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isWorking: true,
      activeRequestId: reqId,
      errorMessage: null,
      preservedInput: '',
    );

    try {
      final history = state.messages
          .where((m) => m.text.trim().isNotEmpty)
          .map((m) => {
                'role': m.role,
                'text': m.text.trim(),
              })
          .toList();

      final preferOffline = _ref?.read(settingsProvider).preferOffline ?? false;
      final req = AnswerRequest(
        requestId: reqId,
        caseId: state.caseId,
        originalMessage: userText.trim(),
        language: language,
        facts: state.facts,
        conversationHistory: history,
        requestedMode: preferOffline ? 'offline' : 'online',
      );

      final res = await _answerRepo.sendTurn(req);

      // Check if response supersedes previous
      List<ChatMessage> updatedMessages = state.messages;
      if (res.supersedesAnswerId != null) {
        updatedMessages = updatedMessages.map((m) {
          if (m.role == 'assistant' &&
              m.response?.answerId == res.supersedesAnswerId) {
            return m.copyWith(isSuperseded: true);
          }
          return m;
        }).toList();
      }

      final assistantMsg = ChatMessage(
        id: 'turn_res_${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        text: res.plainLanguageExplanation?.meaning ??
            res.explanation.firstOrNull?.text ??
            '',
        response: res,
        timestamp: DateTime.now(),
        shouldAnimate: true,
      );

      // Decrement and persist query count locally, synchronizing state
      await _quotaRepo.recordQuery();
      if (res.userQuota != null) {
        _quotaRepo.updateQuota(res.userQuota!);
      }

      state = state.copyWith(
        messages: [...updatedMessages, assistantMsg],
        facts: [...state.facts, ...res.userFacts],
        checklist: res.checklist.isNotEmpty ? res.checklist : state.checklist,
        isWorking: false,
        activeRequestId: null,
      );
      SavedConversationService.saveConversation(state);
    } catch (e) {
      final errorMsg =
          e is AppFailure ? (e.messageBn ?? e.message) : e.toString();
      state = state.copyWith(
        isWorking: false,
        activeRequestId: null,
        errorMessage: errorMsg,
        preservedInput: userText,
      );
    }
  }

  void stop() {
    if (state.activeRequestId != null) {
      _answerRepo.cancel(state.activeRequestId!);
      state = state.copyWith(isWorking: false, activeRequestId: null);
    }
  }

  void toggleChecklistStep(String stepId) {
    final next = state.checklist.map((c) {
      if (c.id == stepId) {
        return c.copyWith(completed: !c.completed);
      }
      return c;
    }).toList();
    state = state.copyWith(checklist: next);
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier(
    ref.watch(answerRepositoryProvider),
    ref.watch(quotaRepositoryProvider),
    ref,
  );
});

// --- Drafts State ---
final savedDraftsProvider = FutureProvider<List<DraftDocument>>((ref) {
  return ref.watch(draftRepositoryProvider).getSavedDrafts();
});
