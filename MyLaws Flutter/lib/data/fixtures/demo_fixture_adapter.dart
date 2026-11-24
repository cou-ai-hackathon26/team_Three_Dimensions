import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../domain/models/answer_request.dart';
import '../../domain/models/answer_response.dart';
import '../../domain/models/draft_document.dart';
import '../../domain/models/fact.dart';
import '../../domain/models/office_record.dart';
import '../../domain/models/pack_state.dart';
import '../../domain/models/source_record.dart';
import '../../domain/models/user_quota.dart';
import '../../domain/repositories/answer_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/draft_repository.dart';
import '../../domain/repositories/office_repository.dart';
import '../../domain/repositories/pack_repository.dart';
import '../../domain/repositories/quota_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/source_repository.dart';

/// Pure isolated demo fixture adapter for development flavor (main_dev.dart).
/// All responses are loaded from synthetic fixtures in contract/fixtures/
/// and honestly marked with engineProvenance = demoFixture.
class DemoFixtureAdapter
    implements
        AnswerRepository,
        SourceRepository,
        OfficeRepository,
        DraftRepository,
        PackRepository,
        AuthRepository,
        QuotaRepository,
        SettingsRepository {
  AuthUser? _currentUser = const AuthUser(
    uid: 'demo_user_001',
    email: 'demo@example.com',
    displayName: 'Demo User',
    isGuest: false,
  );
  UserSettings _settings = const UserSettings();
  final List<DraftDocument> _savedDrafts = [];
  final _quotaController = StreamController<UserQuota>.broadcast();
  final _packStateController = StreamController<PackState>.broadcast();
  final _settingsController = StreamController<UserSettings>.broadcast();
  final _authController = StreamController<AuthUser?>.broadcast();

  DemoFixtureAdapter() {
    _quotaController.add(const UserQuota(
      dailyLimit: 30,
      usedToday: 1,
      remaining: 29,
      canQuery: true,
      store: 'demo_fixture',
    ));
    _packStateController.add(const PackState(
      id: 'bd-pilot-2026-10-27.1',
      legalVersion: '2026-10-26-corpus-v1',
      status: InstallStatus.ready,
      coverage: ['labour', 'cyber', 'consumer', 'property'],
      sizeBytes: 142000,
      completedBytes: 142000,
    ));
  }

  Future<Map<String, dynamic>> _loadJsonFixture(String filename) async {
    try {
      final str = await rootBundle.loadString('contract/fixtures/$filename');
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      // In tests or non-bundle environment, fallback to embedded minimal synthetic fixture
      return {
        'schemaVersion': 1,
        'answerId': 'fixture_fallback',
        'engineProvenance': 'demo_fixture',
        'outcome': 'answered',
        'status': 'completed',
        'sourcePackVersion': 'bd-pilot-2026-10-27.1',
        'checklist': [
          {
            'id': 'step-1',
            'text': '[SYNTHETIC SAMPLE: Dev Fixture]',
            'completed': false,
          }
        ],
        'explanation': [
          {
            'text':
                '[SYNTHETIC SAMPLE: not legal content - fallback demo fixture]',
            'sourceIds': ['sample-1'],
          }
        ],
        'limitations': ['[SYNTHETIC SAMPLE]'],
      };
    }
  }

  // --- AnswerRepository ---
  @override
  Future<AnswerResponse> sendTurn(AnswerRequest request) async {
    // Artificial brief delay to realistically simulate async dispatch
    await Future.delayed(const Duration(milliseconds: 300));

    final msg = request.originalMessage.toLowerCase();

    String fixtureName = 'answered.json';
    if (msg.contains('epz') ||
        msg.contains('sector') ||
        msg.contains('details')) {
      fixtureName = 'clarification.json';
    } else if (msg.contains('আসলে') ||
        msg.contains('actually') ||
        msg.contains('correction')) {
      fixtureName = 'correction_superseded.json';
    } else if (msg.contains('foreign') ||
        msg.contains('আমেরিকা') ||
        msg.contains('ভারত')) {
      fixtureName = 'unsupported_scope.json';
    } else if (msg.contains('জরুরি') ||
        msg.contains('মার্ডার') ||
        msg.contains('emergency')) {
      fixtureName = 'emergency_referral.json';
    } else if (msg.contains('cooking') || msg.contains('রান্না')) {
      fixtureName = 'insufficient_sources.json';
    }

    final json = await _loadJsonFixture(fixtureName);
    return AnswerResponse.fromJson(json);
  }

  @override
  void cancel(String requestId) {}

  // --- SourceRepository ---
  @override
  Future<SourceRecord?> getSourceById(String id) async {
    return SourceRecord(
      id: id,
      type: 'illustrative',
      originalText: '[SYNTHETIC SAMPLE: Statutory passage for $id]',
      title: '[SYNTHETIC SAMPLE] বাংলাদেশ শ্রম আইন, ২০০৬',
      provisionPath: 'ধারা ১২৩ (মজুরি পরিশোধের সময়সীমা)',
      recordVersion: '1.0',
      packVersion: 'bd-pilot-2026-10-27.1',
      legalStatus: 'in_force',
      reviewStatus: 'machine_checked',
      categories: const ['labour'],
    );
  }

  @override
  Future<List<SourceRecord>> searchSources(
      {String? query, String? category}) async {
    return [
      await getSourceById('sample-provision-1') as SourceRecord,
      await getSourceById('sample-provision-2') as SourceRecord,
    ];
  }

  // --- OfficeRepository ---
  @override
  Future<OfficeRecord?> getOfficeById(String id) async {
    return OfficeRecord(
      id: id,
      name:
          '[SYNTHETIC SAMPLE] কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE)',
      address: 'শ্রম ভবন, বিজয়নগর, ঢাকা',
      phone: '02-8391456',
      territory: 'ঢাকা',
      status: 'authoritative',
    );
  }

  @override
  Future<List<OfficeRecord>> getOffices() async {
    return [
      await getOfficeById('dife-dhaka') as OfficeRecord,
      const OfficeRecord(
        id: 'police-999',
        name: 'জাতীয় জরুরি সেবা ৯৯৯',
        phone: '999',
        territory: 'সমগ্র বাংলাদেশ',
        status: 'authoritative',
      ),
    ];
  }

  // --- DraftRepository ---
  @override
  Future<DraftDocument> prepareDraft({
    required DocumentType type,
    required List<Fact> facts,
    String? id,
  }) async {
    final fixtureName = switch (type) {
      DocumentType.gd => 'draft_gd.json',
      DocumentType.dife => 'draft_dife.json',
      DocumentType.dncrp => 'draft_dncrp.json',
      _ => null,
    };
    if (fixtureName != null) {
      final json = await _loadJsonFixture(fixtureName);
      return DraftDocument.fromJson(json);
    }
    return DraftDocument.createDefault(type: type, facts: facts, id: id);
  }

  @override
  Future<void> saveDraft(DraftDocument draft) async {
    _savedDrafts.removeWhere((d) => d.id == draft.id);
    _savedDrafts.add(draft);
  }

  @override
  Future<List<DraftDocument>> getSavedDrafts() async =>
      List.unmodifiable(_savedDrafts);

  @override
  Future<void> deleteDraft(String id) async {
    _savedDrafts.removeWhere((d) => d.id == id);
  }

  // --- PackRepository ---
  @override
  Stream<PackState> watchPackState() => _packStateController.stream;

  @override
  Future<PackState> checkForUpdates() async {
    return const PackState(
      id: 'bd-pilot-2026-10-27.1',
      legalVersion: '2026-10-26-corpus-v1',
      status: InstallStatus.ready,
      coverage: ['labour', 'cyber', 'consumer', 'property'],
      sizeBytes: 142000,
      completedBytes: 142000,
    );
  }

  @override
  Future<void> installPack() async {}

  @override
  Future<void> cancelInstall() async {}

  @override
  Future<void> removePack() async {}

  // --- AuthRepository ---
  @override
  Stream<AuthUser?> authStateChanges() {
    if (_currentUser != null) {
      scheduleMicrotask(() => _authController.add(_currentUser));
    }
    return _authController.stream;
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    _currentUser =
        AuthUser(uid: 'user_syn_123', email: email, displayName: 'Test User');
    _authController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> signUpWithEmail(String email, String password) async {
    _currentUser =
        AuthUser(uid: 'user_syn_123', email: email, displayName: 'Test User');
    _authController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> signInWithGoogle([String idToken = 'mock_id_token', String? email]) async {
    _currentUser = AuthUser(
      uid: 'google_syn_123',
      email: email ?? 'google_user@example.com',
      displayName: email != null && email.contains('@')
          ? email.split('@').first
          : 'Google User',
    );
    _authController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> continueAsGuest() async {
    _currentUser = const AuthUser(uid: 'guest_syn', isGuest: true);
    _authController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authController.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    _currentUser = null;
    _authController.add(null);
  }

  // --- QuotaRepository ---
  @override
  Future<UserQuota> getQuota() async {
    return const UserQuota(
      dailyLimit: 30,
      usedToday: 1,
      remaining: 29,
      canQuery: true,
      store: 'demo_fixture',
    );
  }

  @override
  Stream<UserQuota> watchQuota() => _quotaController.stream;

  @override
  Future<UserQuota> recordQuery() async {
    final cur = await getQuota();
    final used = cur.usedToday + 1;
    final rem = (cur.dailyLimit - used).clamp(0, cur.dailyLimit);
    final next = cur.copyWith(
      usedToday: used,
      remaining: rem,
      canQuery: rem > 0,
    );
    _quotaController.add(next);
    return next;
  }

  @override
  void updateQuota(UserQuota quota) {
    _quotaController.add(quota);
  }

  // --- SettingsRepository ---
  @override
  Future<UserSettings> getSettings() async => _settings;

  @override
  Stream<UserSettings> watchSettings() => _settingsController.stream;

  @override
  Future<void> updateSettings(UserSettings settings) async {
    _settings = settings;
    _settingsController.add(_settings);
  }
}
