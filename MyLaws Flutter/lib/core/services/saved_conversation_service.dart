import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/providers.dart';
import '../../domain/models/answer_response.dart';
import '../../domain/models/checklist_step.dart';
import '../../domain/models/claim.dart';
import '../../domain/models/fact.dart';

/// Representation of a persistent saved legal consultation session
class SavedConversation {
  final String id;
  final String title;
  final String snippet;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int turnCount;
  final List<ChatMessage> messages;
  final List<Fact> facts;
  final List<ChecklistStep> checklist;

  const SavedConversation({
    required this.id,
    required this.title,
    required this.snippet,
    required this.createdAt,
    required this.updatedAt,
    required this.turnCount,
    required this.messages,
    this.facts = const [],
    this.checklist = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'snippet': snippet,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'turnCount': turnCount,
        'messages': messages.map((m) => m.toJson()).toList(),
        'facts': facts.map((f) => f.toJson()).toList(),
        'checklist': checklist.map((c) => c.toJson()).toList(),
      };

  factory SavedConversation.fromJson(Map<String, dynamic> json) {
    final msgList = (json['messages'] as List<dynamic>? ?? [])
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();

    final factsList = (json['facts'] as List<dynamic>? ?? [])
        .map((f) => Fact.fromJson(f as Map<String, dynamic>))
        .toList();

    final checklistList = (json['checklist'] as List<dynamic>? ?? [])
        .map((c) => ChecklistStep.fromJson(c as Map<String, dynamic>))
        .toList();

    return SavedConversation(
      id: json['id'] as String,
      title: json['title'] as String,
      snippet: json['snippet'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      turnCount: json['turnCount'] as int? ?? msgList.length,
      messages: msgList,
      facts: factsList,
      checklist: checklistList,
    );
  }
}

/// Persistent service that manages citizen conversation history
class SavedConversationService {
  static const String _storageKey = 'saved_conversations_v1';

  static List<SavedConversation>? _memoryCache;

  /// Retrieves all saved conversations, populating default realistic legal cases if empty
  static Future<List<SavedConversation>> getConversations() async {
    if (_memoryCache != null) return _memoryCache!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _memoryCache = decoded
            .map((item) =>
                SavedConversation.fromJson(item as Map<String, dynamic>))
            .toList();
        return _memoryCache!;
      }
    } catch (_) {}

    // Initial defaults for realistic demonstration
    _memoryCache = _buildDefaultConversations();
    await _persist();
    return _memoryCache!;
  }

  /// Automatically saves or updates the active conversation state
  static Future<void> saveConversation(ConversationState state) async {
    if (state.messages.isEmpty) return;

    final list = await getConversations();

    // Derive readable title from the first citizen question
    final firstUserMsg =
        state.messages.where((m) => m.role == 'user').firstOrNull?.text ?? '';
    final title = firstUserMsg.isNotEmpty
        ? (firstUserMsg.length > 40
            ? '${firstUserMsg.substring(0, 40)}...'
            : firstUserMsg)
        : 'আইনি পরামর্শ অধিবেশন';

    // Derive snippet from the latest assistant response meaning
    final lastAssistant =
        state.messages.where((m) => m.role == 'assistant').lastOrNull;
    final snippet = lastAssistant?.text.isNotEmpty == true
        ? (lastAssistant!.text.length > 70
            ? '${lastAssistant.text.substring(0, 70)}...'
            : lastAssistant.text)
        : firstUserMsg;

    final existingIndex = list.indexWhere((c) => c.id == state.caseId);
    final now = DateTime.now();

    final item = SavedConversation(
      id: state.caseId,
      title: title,
      snippet: snippet,
      createdAt: existingIndex >= 0 ? list[existingIndex].createdAt : now,
      updatedAt: now,
      turnCount: state.messages.length,
      messages: state.messages,
      facts: state.facts,
      checklist: state.checklist,
    );

    if (existingIndex >= 0) {
      list[existingIndex] = item;
    } else {
      list.insert(0, item);
    }

    _memoryCache = list;
    await _persist();
  }

  /// Deletes a saved conversation by ID
  static Future<void> deleteConversation(String id) async {
    final list = await getConversations();
    list.removeWhere((c) => c.id == id);
    _memoryCache = list;
    await _persist();
  }

  static Future<void> _persist() async {
    if (_memoryCache == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_memoryCache!.map((c) => c.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }

  static List<SavedConversation> _buildDefaultConversations() {
    return [
      SavedConversation(
        id: 'conv_sample_gd_01',
        title: 'মোবাইল ফোন হারানোর সাধারণ ডায়েরি (GD)',
        snippet: 'গত ২৭ অক্টোবর ধানমন্ডি লেক থেকে ফোন হারিয়েছি...',
        createdAt: DateTime(2026, 10, 27, 14, 30),
        updatedAt: DateTime(2026, 10, 27, 14, 35),
        turnCount: 4,
        messages: [
          ChatMessage(
            id: 'turn_user_gd',
            role: 'user',
            text:
                'আমার মোবাইল ফোন ধানমন্ডি লেকে হারিয়ে গেছে, এখন থানায় জিডি কীভাবে করব?',
            timestamp: DateTime(2026, 10, 27, 14, 30),
          ),
          ChatMessage(
            id: 'turn_asst_gd',
            role: 'assistant',
            text:
                'মোবাইল ফোন হারিয়ে গেলে ভবিষ্যতে সিম বা আইএমইআই অপব্যবহার রোধে নিকটস্থ থানায় সাধারণ ডায়েরি (জিডি) করা বাধ্যতামূলক। অনলাইনে বা সরাসরি থানায় গিয়ে জিডি ফর্ম পূরণ করে জমা দিতে পারেন।',
            timestamp: DateTime(2026, 10, 27, 14, 31),
            response: const AnswerResponse(
              answerId: 'ans_sample_gd',
              engineProvenance: ProcessingEngine.onlineMeta,
              outcome: Outcome.answered,
              status: 'completed',
              sourcePackVersion: 'bd-pilot-2026-10-27.1',
              problemSummary: ProblemSummary(
                identifiedIssue: 'মোবাইল ফোন হারানো ও জিডি আবেদন',
                understanding:
                    'আপনি হারিয়ে যাওয়া মোবাইল ফোনের আইনি সুরক্ষায় জিডি করার উপায় জানতে চেয়েছেন।',
              ),
              plainLanguageExplanation: PlainLanguageExplanation(
                heading: 'হারানো মোবাইলের জিডি ও নাগরিক সুরক্ষা',
                meaning:
                    'মোবাইল ফোন হারিয়ে গেলে অবিলম্বে থানায় জিডি করা অত্যন্ত গুরুত্বপূর্ণ। এর ফলে ফোনটি অপব্যবহার হলে আপনি আইনি দায়মুক্তি পাবেন এবং পুলিশি ট্র্যাকিং শুরু হবে।',
                userRightsAndOptions: [
                  'থানায় বিনামূল্যে সাধারণ ডায়েরি (জিডি) অন্তর্ভুক্তির সংবিধিবদ্ধ অধিকার',
                  'জিডি নম্বরের সত্যায়িত অনুলিপি সংগ্রহের অধিকার',
                ],
                whatToDoNext:
                    'ফোনের আইএমইআই (IMEI) নম্বর ও ক্রয়ের রশিদ নিয়ে থানায় লিখিত আবেদন করুন।',
              ),
              explanation: [
                Claim(
                  text:
                      'পুলিশ রেগুলেশন বেঙ্গল (PRB) ৩৭৭ প্রবিধান অনুযায়ী হারানো সম্পত্তির জিডি গ্রহণ বাধ্যতামূলক।',
                  sourceIds: ['prb-377'],
                ),
              ],
              checklist: [
                ChecklistStep(
                  id: 'gd_step_1',
                  text: 'ফোনের আইএমইআই (IMEI) ও সিম কার্ড নম্বর সংগ্রহ করুন',
                  completed: true,
                ),
                ChecklistStep(
                  id: 'gd_step_2',
                  text: 'নিকটস্থ মডেল থানায় জিডি আবেদনপত্র দাখিল করুন',
                  completed: false,
                ),
                ChecklistStep(
                  id: 'gd_step_3',
                  text:
                      'দায়িত্বরত অফিসারের স্বাক্ষরযুক্ত জিডি নম্বর ও কপি সংগ্রহ করুন',
                  completed: false,
                ),
              ],
              draftOffer: DraftOffer(
                prompt: 'জিডি খসড়া প্রস্তুত করতে চান?',
                documentType: 'gd',
                documentTitle: 'থানায় সাধারণ ডায়েরি (General Diary - GD)',
                description:
                    'ভবিষ্যত আইনি নিরাপত্তা ও পুলিশি তদন্তের জন্য নিকটস্থ থানায় দাখিলযোগ্য সাধারণ ডায়েরির আবেদনপত্র।',
              ),
            ),
          ),
        ],
        checklist: const [
          ChecklistStep(
            id: 'gd_step_1',
            text: 'ফোনের আইএমইআই (IMEI) ও সিম কার্ড নম্বর সংগ্রহ করুন',
            completed: true,
          ),
          ChecklistStep(
            id: 'gd_step_2',
            text: 'নিকটস্থ মডেল থানায় জিডি আবেদনপত্র দাখিল করুন',
            completed: false,
          ),
          ChecklistStep(
            id: 'gd_step_3',
            text:
                'দায়িত্বরত অফিসারের স্বাক্ষরযুক্ত জিডি নম্বর ও কপি সংগ্রহ করুন',
            completed: false,
          ),
        ],
      ),
      SavedConversation(
        id: 'conv_sample_labour_01',
        title: 'বকেয়া বেতন ও শ্রম আদালত অভিযোগ',
        snippet: 'কোম্পানি ৩ মাসের বেতন বকেয়া রেখেছে...',
        createdAt: DateTime(2026, 10, 25, 10, 15),
        updatedAt: DateTime(2026, 10, 25, 10, 22),
        turnCount: 6,
        messages: [
          ChatMessage(
            id: 'turn_user_labour',
            role: 'user',
            text:
                'কোম্পানি গত ৩ মাস ধরে আমার বেতন দিচ্ছে না। আমি কীভাবে বকেয়া বেতন আদায় করতে পারি?',
            timestamp: DateTime(2026, 10, 25, 10, 15),
          ),
          ChatMessage(
            id: 'turn_asst_labour',
            role: 'assistant',
            text:
                'বাংলাদেশ শ্রম আইন, ২০০৬ অনুযায়ী কাজ সম্পন্ন করার পর নির্ধারিত সময়ে পারিশ্রমিক পাওয়া শ্রমিকের অলঙ্ঘনীয় অধিকার। ৩ মাস বেতন বকেয়া রাখা আইনত দণ্ডনীয় অপরাধ। আপনি বকেয়া বেতনের সাথে অতিরিক্ত ২৫% পর্যন্ত ক্ষতিপূরণ দাবি করতে পারেন।',
            timestamp: DateTime(2026, 10, 25, 10, 16),
            response: const AnswerResponse(
              answerId: 'ans_sample_labour',
              engineProvenance: ProcessingEngine.onlineMeta,
              outcome: Outcome.answered,
              status: 'completed',
              sourcePackVersion: 'bd-pilot-2026-10-27.1',
              problemSummary: ProblemSummary(
                identifiedIssue: 'বকেয়া মজুরি ও ক্ষতিপূরণ দাবি',
                understanding:
                    'আপনি ৩ মাস ধরে বকেয়া বেতন না পাওয়ার বিষয়ে প্রতিকার জানতে চেয়েছেন।',
              ),
              plainLanguageExplanation: PlainLanguageExplanation(
                heading: 'বকেয়া মজুরি আদায়ে আপনার সংবিধিবদ্ধ অধিকার',
                meaning:
                    'বাংলাদেশ শ্রম আইন, ২০০৬ এর ধারা ১২৩ অনুযায়ী কাজ করার পর নির্ধারিত সময়ের মধ্যে পারিশ্রমিক পাওয়া শ্রমিকের আইনি অধিকার। ৩ মাস বেতন বকেয়া রাখা আইনত দণ্ডনীয় অপরাধ। ধারা ১৩২ অনুযায়ী আপনি বকেয়া বেতনের সাথে অতিরিক্ত ক্ষতিপূরণ দাবি করতে পারেন।',
                userRightsAndOptions: [
                  'মালিকপক্ষকে বকেয়া পরিশোধের জন্য লিখিত নোটিশ প্রদান',
                  'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তরে (DIFE) সরাসরি অভিযোগ দাখিল',
                  'শ্রম আদালতে ধারা ১৩২ অনুযায়ী বকেয়া মজুরি ও ক্ষতিপূরণ আদায়ে মোকদ্দমা',
                ],
                whatToDoNext:
                    'সর্বপ্রথম আপনার নিয়োগপত্র ও ব্যাংকের নথি গুছিয়ে মালিকপক্ষকে লিখিত নোটিশ দিন।',
              ),
              explanation: [
                Claim(
                  text:
                      'বাংলাদেশ শ্রম আইন ২০০৬ এর ১২৩ ধারা অনুযায়ী মজুরি কাল সমাপ্তির পরবর্তী ৭ কর্মদিবসের মধ্যে মজুরি পরিশোধ বাধ্যতামূলক।',
                  sourceIds: ['labour-act-123'],
                ),
              ],
              checklist: [
                ChecklistStep(
                  id: 'labour_step_1',
                  text: 'নিয়োগপত্র, পরিচয়পত্র ও হাজিরা রেকর্ড সংগ্রহ করুন',
                  completed: true,
                ),
                ChecklistStep(
                  id: 'labour_step_2',
                  text:
                      'মালিকপক্ষকে ১৫ দিনের সময় দিয়ে লিখিত লিগ্যাল নোটিশ পাঠান',
                  completed: false,
                ),
                ChecklistStep(
                  id: 'labour_step_3',
                  text:
                      'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE)-এ অভিযোগ দাখিল করুন',
                  completed: false,
                ),
              ],
              draftOffer: DraftOffer(
                prompt: 'DIFE অভিযোগ খসড়া প্রস্তুত করতে চান?',
                documentType: 'dife',
                documentTitle:
                    'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE) অভিযোগ',
                description:
                    'বাংলাদেশ শ্রম আইন ২০০৬ অনুযায়ী বকেয়া বেতন ও ক্ষতিপূরণ আদায়ে DIFE বরাবর আনুষ্ঠানিক অভিযোগ।',
              ),
            ),
          ),
        ],
        checklist: const [
          ChecklistStep(
            id: 'labour_step_1',
            text: 'নিয়োগপত্র, পরিচয়পত্র ও হাজিরা রেকর্ড সংগ্রহ করুন',
            completed: true,
          ),
          ChecklistStep(
            id: 'labour_step_2',
            text: 'মালিকপক্ষকে ১৫ দিনের সময় দিয়ে লিখিত লিগ্যাল নোটিশ পাঠান',
            completed: false,
          ),
          ChecklistStep(
            id: 'labour_step_3',
            text:
                'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE)-এ অভিযোগ দাখিল করুন',
            completed: false,
          ),
        ],
      ),
    ];
  }
}
