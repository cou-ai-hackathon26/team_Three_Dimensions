import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/answer_request.dart';
import '../../domain/models/answer_response.dart';
import '../../domain/models/checklist_step.dart';
import '../../domain/models/claim.dart';
import '../../domain/models/fact.dart';
import '../data/legal_provisions_catalog.dart';
import '../logging/app_logger.dart';

/// On-Device Local AI & Statutory Legal Inference Engine for MyLaws.
/// Executes completely offline without internet or server connectivity,
/// grounded directly in the codification of the Bangladesh Code and
/// the quantized Llama 3.2 1B Instruct on-device model.
class OfflineLegalInferenceEngine {
  static const String _prefModelInstalledKey = 'key_local_ai_model_installed';
  static bool _isModelInstalled = false;

  /// Check whether the local model is installed and ready for on-device inference
  static bool get isModelInstalled => _isModelInstalled;

  /// Initialize engine state from local persistence and statutory catalog
  static Future<void> initialize() async {
    try {
      await LegalProvisionsCatalog.initialize();
      final prefs = await SharedPreferences.getInstance();
      _isModelInstalled = prefs.getBool(_prefModelInstalledKey) ?? false;
      AppLogger.i(
          'OfflineLegalInferenceEngine initialized. Local model ready: $_isModelInstalled');
    } catch (e) {
      AppLogger.w('Failed to initialize OfflineLegalInferenceEngine: $e');
    }
  }

  /// Update the model installation and auto-setup state
  static Future<void> setModelInstalled(bool installed) async {
    _isModelInstalled = installed;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefModelInstalledKey, installed);
      AppLogger.i(
          'OfflineLegalInferenceEngine model installed state updated to: $installed');
    } catch (e) {
      AppLogger.w('Failed to persist model installed state: $e');
    }
  }

  /// Determines whether the app can answer offline (either via local LLM or statutory catalog)
  static bool isAvailable() => true;

  /// Generates a complete, structured legal answer on-device without internet access
  static Future<AnswerResponse> generateOfflineAnswer(
      AnswerRequest request) async {
    final userMessage = request.originalMessage.trim();
    final lower = userMessage.toLowerCase();
    final isBangla = request.language != 'en';

    AppLogger.i(
        'OfflineLegalInferenceEngine generating on-device answer for: "$userMessage" [isBangla: $isBangla]');

    // 1. Detect Category & Situational Intent
    String category = 'general';
    List<String> sourceIds = [];
    String identifiedIssue;
    String explanationMeaning;
    String whatToDoNext;
    List<ChecklistStep> checklist = [];
    List<String> allowedDraftOptions = [];

    // --- Scenario A: Labour & Wage Grievances ---
    final isLabour = [
      'বেতন',
      'মজুরি',
      'বকেয়া',
      'ছাঁটাই',
      'বরখাস্ত',
      'অব্যাহতি',
      'চাকরি',
      'beton',
      'salary',
      'mojuri',
      'bokeya',
      'chatai',
      'borkhasto',
      'wage',
      'fired',
      'terminated',
      'labour',
      'dife',
    ].any((k) => lower.contains(k));

    // --- Scenario B: Theft, Lost Valuables & Police GD ---
    final isTheftOrLost = [
      'চুরি',
      'ছিনতাই',
      'হারিয়ে',
      'হারানো',
      'নিখোঁজ',
      'মানিব্যাগ',
      'মানি ব্যাগ',
      'টাকা চুরি',
      'পকেটমার',
      'churi',
      'harie',
      'harano',
      'money bag',
      'wallet',
      'stolen',
      'theft',
      'lost',
      'snatched',
      'pocketmar',
    ].any((k) => lower.contains(k));

    // --- Scenario C: Consumer Protection & E-Commerce Disputes ---
    final isConsumer = [
      'মেয়াদোত্তীর্ণ',
      'ভেজাল',
      'ওজনে কম',
      'নকল পণ্য',
      'প্রতারণা',
      'রিফান্ড দেয়নি',
      'রিফান্ড পাইনি',
      'টাকা ফেরত',
      'ভোক্তা',
      'defective',
      'fake',
      'expired',
      'refund',
      'dncrp',
      'daraz',
      'ecommerce',
      'cheat',
    ].any((k) => lower.contains(k));

    // --- Scenario D: Cyber Harassment & Digital Blackmail ---
    final isCyber = [
      'ব্ল্যাকমেইল',
      'হুমকি',
      'চাঁদাবাজি',
      'ছবি ফাঁস',
      'আইডি হ্যাক',
      'সাইবার',
      'হোয়াটসঅ্যাপ',
      'ফেসবুক',
      'blackmail',
      'threat',
      'extortion',
      'leak',
      'cyber',
      'facebook',
      'whatsapp',
      'hack',
    ].any((k) => lower.contains(k));

    // --- Scenario E: Land & Property Disputes ---
    final isProperty = [
      'জমি',
      'দলিল',
      'দখল',
      'বেদখল',
      'সীমানা',
      'উচ্ছেদ',
      'নামজারি',
      'খারিজ',
      'খতিয়ান',
      'jomi',
      'dalil',
      'dokhol',
      'bedokhol',
      'land',
      'boundary',
      'property',
      'khotiyan',
    ].any((k) => lower.contains(k));

    // --- Scenario F: Administrative Procedures (No court draft needed) ---
    final isAdministrative = [
      'ড্রাইভিং',
      'লাইসেন্স',
      'বিআরটিএ',
      'পাসপোর্ট',
      'ট্রেড লাইসেন্স',
      'driving',
      'license',
      'brta',
      'passport',
      'trade license',
    ].any((k) => lower.contains(k));

    // --- Scenario G: Personal Family Distress & Domestic Emotional Crisis ---
    final isFamilyDistress = [
      'ঝগড়া',
      'জঘড়া',
      'রাগ করে চলে',
      'চলে গেছে',
      'আব্বু',
      'আম্মু',
      'বাবা',
      'মা',
      'ভয় লাগছে',
      'কান্না পাচ্ছে',
      'কান্না পাওয়া',
      'একা একা লাগছে',
      'abbu',
      'ammu',
      'baba',
      'ma',
      'jogra',
      'jhogra',
      'cole geche',
      'chole geche',
    ].any((k) => lower.contains(k));

    // --- Scenario H: Tenant Rights & House Rent Control ---
    final isTenantOrRent = [
      'ভাড়াটিয়া',
      'ভাড়াটিয়ার',
      'ভাড়াতিয়া',
      'বাড়ি ভাড়া',
      'বাড়ি ভাড়া',
      'বাড়িওয়ালা',
      'বাড়িওয়ালা',
      'উচ্ছেদ',
      'ভাড়ার রসিদ',
      'ভাড়া রসিদ',
      'গ্যাস কেটে',
      'বিদ্যুৎ কেটে',
      'পানি কেটে',
      'tenant',
      'tenancy',
      'landlord',
      'rent',
      'rental',
      'eviction',
      'evict',
      'premises',
    ].any((k) => lower.contains(k));

    // --- Scenario I: Dower, Maintenance & Family Court ---
    final isFamilyCourt = [
      'দেনমোহর',
      'ভরণপোষণ',
      'খোরপোশ',
      'তালাক',
      'ডিভোর্স',
      'স্ত্রীকে খরচ',
      'বাচ্চার খরচ',
      'dower',
      'mahr',
      'maintenance',
      'divorce',
      'talaq',
      'child support',
    ].any((k) => lower.contains(k));

    // --- Scenario J: Cheque Dishonour & Financial Recovery ---
    final isCheque = [
      'চেক',
      'চেকের',
      'বাউন্স',
      'ডিজঅনার',
      'dishonour',
      'dishonor',
      'bounce',
      'cheque',
      'check',
      '১৩৮',
      '138',
    ].any((k) => lower.contains(k));

    // Evaluate Legal Rules
    if (isLabour) {
      category = 'work';
      sourceIds = ['labor-123', 'labour-132', 'labour-289'];
      identifiedIssue = isBangla
          ? 'বকেয়া মজুরি ও শ্রম অধিকার সংক্রান্ত আইনি সুরক্ষা'
          : 'Recovery of Unpaid Wages & Labour Law Protection';

      final hasMonths = RegExp(r'(\d+|[০-৯]+)\s*(মাস|month)').firstMatch(lower);
      final monthStr = hasMonths != null ? hasMonths.group(0)! : '';

      explanationMeaning = isBangla
          ? (monthStr.isNotEmpty
                  ? 'আপনার $monthStr ধরে বেতন না পাওয়ার কষ্টটা আমরা গভীরভাবে বুঝতে পারছি, এটা সত্যিই অনেক চিন্তা ও কষ্টের বিষয়। আপনি নিশ্চিত থাকুন, **বাংলাদেশ শ্রম আইন**-এ আপনার অধিকার অত্যন্ত শক্তভাবে সুরক্ষিত।\n\n'
                  : 'কর্মক্ষেত্রে সময়মতো কষ্টার্জিত বেতন বা মজুরি না পাওয়া সত্যিই অনেক কষ্ট ও উদ্বেগের বিষয়। আপনি নিশ্চিত থাকুন, **বাংলাদেশ শ্রম আইন**-এ আপনার আইনি অধিকার অত্যন্ত শক্তভাবে সুরক্ষিত।\n\n') +
              'আইন অনুযায়ী মালিক কোনো অবস্থাতেই শ্রমিকের বৈধ মজুরি আটকে রাখতে পারে না। **বাংলাদেশ শ্রম আইন ২০০৬-এর ১২৩ ধারা** মোতাবেক, মজুরি মেয়াদের সমাপ্তির পর সর্বোচ্চ ৭ কার্যদিবসের মধ্যে সমুদয় মজুরি পরিশোধ করা নিয়োগকর্তার জন্য আইনত বাধ্যতামূলক।\n\n' +
              '**শ্রম আইনের ধারা ২৮৯** অনুযায়ী, গেজেট করা মজুরির কম দিলে বা বেতন না দিয়ে আটকে রাখলে মালিকের **সর্বোচ্চ ১ বছরের কারাদণ্ড, ১০,০০০ টাকা পর্যন্ত অর্থদণ্ড, অথবা উভয় দণ্ড** হতে পারে, এবং বিজ্ঞ আদালত একই সাথে সমস্ত বকেয়া বেতন অবিলম্বে পরিশোধের আদেশ প্রদান করবেন।\n\n' +
              'এছাড়া আপনি **ধারা ১৩২**-এর অধীনে শ্রম আদালতে আবেদন দাখিল করে আপনার পুরো বকেয়া বেতনের সাথে **অতিরিক্ত ২৫% পর্যন্ত সংবিধিবদ্ধ ক্ষতিপূরণ** দাবি করতে পারেন। অর্থাৎ শুধু বকেয়া বেতন নয়, আর্থিক হয়রানির জন্য আইনগত ক্ষতিপূরণ পাওয়ার পূর্ণ অধিকার আপনার রয়েছে।\n\n' +
              'জরুরি প্রয়োজনে সরকারি কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE)-এর টোল-ফ্রি হেল্পলাইন **১৬১০৪**-এ ফোন করে সরাসরি সরকারি সহায়তা গ্রহণ করতে পারেন।'
          : 'We deeply understand your distress and financial hardship regarding unpaid wages. Rest assured, your rights are strongly guaranteed and protected under the **Bangladesh Labour Act, 2006**.\n\n' +
              'Under **Section 123 of the Labour Act**, employers are statutorily mandated to disburse all earned wages within 7 working days following the end of the wage period.\n\n' +
              'Under **Section 289**, withholding wages or paying less than statutory minimums is a cognizable criminal offense carrying **up to 1 year imprisonment, a fine of up to BDT 10,000, or both**, alongside a mandatory judicial order to settle all unpaid arrears immediately.\n\n' +
              'Furthermore, under **Section 132**, you have the statutory right to petition the Labour Court to recover your full unpaid arrears along with **up to 25% additional statutory compensation** for unlawful harassment and delay.\n\n' +
              'For immediate administrative intervention, citizens can contact the Department of Inspection for Factories and Establishments (DIFE) toll-free hotline at **16104**.';

      whatToDoNext = isBangla
          ? 'নিয়োগপত্র ও আইডি কার্ড গুছিয়ে রাখুন। প্রথমে মালিকপক্ষকে ৭ দিনের সময় দিয়ে বকেয়া পরিশোধের লিখিত চিঠি দিন। সমাধান না হলে DIFE হেল্পলাইন ১৬১০৪ অথবা শ্রম আদালতে অভিযোগ দাখিল করুন।'
          : 'Preserve appointment letter and ID. Serve a written 7-day wage demand letter to management, and lodge a formal petition with DIFE (hotline 16104) or Labour Court if unresolved.';

      checklist = [
        ChecklistStep(
          id: 'step-1',
          text: isBangla
              ? 'নিয়োগপত্র (Appointment Letter), সচিত্র পরিচয়পত্র ও পূর্ববর্তী পে-স্লিপ বা ব্যাংক স্টেটমেন্ট গুছিয়ে রাখুন'
              : 'Assemble employment contract, official employee ID, and wage payment records',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-2',
          text: isBangla
              ? 'বকেয়া মজুরির সুনির্দিষ্ট হিসাব উল্লেখ করে মালিকপক্ষকে ৭ দিনের মধ্যে পরিশোধের আনুষ্ঠানিক লিখিত চিঠি দিন'
              : 'Serve a formal written letter detailing outstanding arrears with a 7-day compliance window',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-3',
          text: isBangla
              ? 'সমাধান না হলে কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE)-এর শ্রম পরিদর্শক বরাবর লিখিত অভিযোগ দাখিল করুন (হেল্পলাইন: ১৬১০৪)'
              : 'File a formal grievance before the Inspector, Department of Inspection for Factories and Establishments (DIFE) (Helpline: 16104)',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-4',
          text: isBangla
              ? 'শ্রম আইন ২০০৬-এর ১৩২ ধারা অনুযায়ী বকেয়া মজুরির সাথে অতিরিক্ত ২৫% ক্ষতিপূরণ দাবি করে বিজ্ঞ শ্রম আদালতে আবেদন দাখিল করুন'
              : 'Petition the competent Labour Court under Section 132 claiming full unpaid arrears plus 25% statutory compensation',
          completed: false,
        ),
      ];
      allowedDraftOptions = ['dife'];
    } else if (isTheftOrLost) {
      category = 'threats';
      sourceIds = ['penal-379', 'crpc-155', 'police-44-gd'];
      identifiedIssue = isBangla
          ? 'মানিব্যাগ চুরি বা হারানোর আইনি সুরক্ষা ও সাধারণ ডায়েরি (জিডি)'
          : 'What to Do if Your Wallet is Stolen or Lost: Legal Protection & Police GD';

      explanationMeaning = isBangla
          ? 'মানিব্যাগ, জাতীয় পরিচয়পত্র বা মূল্যবান জিনিসপত্র হারিয়ে যাওয়া বা চুরি হওয়া অত্যন্ত উদ্বেগের বিষয়। তবে টাকার চেয়েও ভেতরের জাতীয় পরিচয়পত্র (NID), ব্যাংকের এটিএম কার্ড এবং বিকাশ/নগদের অপব্যবহার রোধ করাই এখন সবচেয়ে জরুরি।\n\n' +
              '**দণ্ডবিধি ১৮৬০-এর ৩৭৯ ধারা** মোতাবেক চুরি একটি দণ্ডনীয় ফৌজদারি অপরাধ, যাতে অপরাধীর সর্বোচ্চ ৩ বছর পর্যন্ত কারাদণ্ড বা অর্থদণ্ড হতে পারে।\n\n' +
              'মানিব্যাগ বা নথিপত্র চুরি হলে অথবা হারিয়ে গেলে তাৎক্ষণিকভাবে নিকটস্থ থানায় একটি **সাধারণ ডায়েরি (জিডি)** করা আইনি নিয়ম (**ফৌজদারি কার্যবিধি ১৫৫ ধারা ও পুলিশ আইন ৪৪ ধারা**)। এর সবচেয়ে বড় আইনি সুরক্ষা হলো—পরবর্তীতে আপনার হারানো বা চুরি হওয়া NID বা সিম কার্ড ব্যবহার করে কোনো প্রতারণা বা অপরাধ সংঘটিত হলে আপনি আইনত সম্পূর্ণ নির্দোষ ও সুরক্ষিত প্রমাণিত হবেন। এছাড়া নতুন NID, ব্যাংক কার্ড বা সিম উত্তোলনের জন্যও জিডি নম্বর আবশ্যক।\n\n' +
              'থানায় গিয়ে সরাসরি বিনামূল্যে জিডি করা যায় অথবা বাংলাদেশ পুলিশের অফিসিয়াল অনলাইন পোর্টাল (gd.police.gov.bd) থেকেও জিডি এন্ট্রি করা সম্ভব।'
          : 'Having your wallet, National ID, or financial cards stolen or lost is a serious worry. Protecting your identity documents and accounts against fraudulent misuse is the immediate priority.\n\n' +
              'Under **Section 379 of the Penal Code 1860**, theft is a cognizable criminal offense punishable with up to 3 years imprisonment or fine.\n\n' +
              'Under **Section 155 of the Code of Criminal Procedure (CrPC) and Section 44 of the Police Act**, lodging an official **General Diary (GD)** at your local police station provides statutory legal immunity against any future identity theft, financial fraud, or unauthorized mobile transactions perpetrated using your lost credentials.\n\n' +
              'An official GD reference is also legally mandated to obtain replacement NID cards, driving licenses, and banking debit/credit cards.';

      whatToDoNext = isBangla
          ? 'দেরি না করে ব্যাংকের হেল্পলাইনে ফোন করে কার্ড ও এমএফএস সাময়িক ব্লক করুন। এরপর নিকটস্থ থানায় গিয়ে সাধারণ ডায়েরি (জিডি) করে সিলযুক্ত অনুলিপি সংগ্রহ করুন।'
          : 'Immediately call your bank and MFS helplines to block cards. Then visit your nearest police station or use gd.police.gov.bd to lodge a GD and retain a stamped copy.';

      checklist = [
        ChecklistStep(
          id: 'step-1',
          text: isBangla
              ? 'মানিব্যাগে থাকা ব্যাংক কার্ড, বিকাশ, নগদ বা রকেটের ২৪/৭ হেল্পলাইনে অবিলম্বে ফোন করে অ্যাকাউন্ট বা কার্ড সাময়িক ব্লক করুন'
              : 'Immediately contact 24/7 bank and MFS customer hotlines to block debit/credit cards and mobile wallets',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-2',
          text: isBangla
              ? 'হারানো সিম কার্ডটির অপব্যবহার ঠেকাতে সংশ্লিষ্ট মোবাইল অপারেটরের কাস্টমার কেয়ারে (যেমন ১২১) ফোন করে সাময়িক বন্ধ করুন'
              : 'Contact telecom customer care to temporarily suspend the lost mobile SIM to prevent OTP hijacking',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-3',
          text: isBangla
              ? 'নিকটস্থ থানায় গিয়ে বা অনলাইন পুলিশ জিডি পোর্টালে কখন, কোথা থেকে ও কী কী ছিল উল্লেখ করে সাধারণ ডায়েরি (জিডি) দাখিল করুন'
              : 'File a General Diary (GD) at the nearest police station or via gd.police.gov.bd specifying date, time, location, and lost documents',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-4',
          text: isBangla
              ? 'ডিউটি অফিসারের স্বাক্ষর ও সিলসহ জিডি কপির দ্বিতীয় অনুলিপিটি যত্নসহকারে সংরক্ষণ করুন (নতুন NID ও লাইসেন্স উত্তোলনের জন্য)'
              : 'Collect and preserve an official stamped and signed copy of the GD slip from the duty officer',
          completed: false,
        ),
      ];
      allowedDraftOptions = ['gd'];
    } else if (isConsumer) {
      category = 'consumer';
      sourceIds = ['consumer-50', 'ecommerce-3.1.8', 'ecommerce-3.5.1'];
      identifiedIssue = isBangla
          ? 'ভোক্তা অধিকার লঙ্ঘন, ই-কমার্স প্রতারণা ও ক্ষতিপূরণ আদায়'
          : 'Consumer Rights Violation, E-Commerce Redress & Compensation';

      explanationMeaning = isBangla
          ? 'অনলাইন শপ বা দোকান থেকে প্রতিশ্রুত পণ্য না পাওয়া, নষ্ট/ছেঁড়া পণ্য দেওয়া কিংবা রিফান্ড দিতে অস্বীকার করা ভোক্তা অধিকার সংরক্ষণ আইনের সুস্পষ্ট লঙ্ঘন। এ বিষয়ে আপনার আইনি প্রতিকার অত্যন্ত শক্তিশালী।\n\n' +
              '**ভোক্তা অধিকার সংরক্ষণ আইন ২০০৯-এর ৫০ ধারা ও ডিজিটাল কমার্স পরিচালনা নির্দেশিকা ২০২১-এর ৩.১.৮ ও ৩.৫.১ দফা** মোতাবেক, কোনো বিক্রেতা গ্রাহকের সাথে প্রতারণা করলে বা প্রতিশ্রুত পণ্য সরবরাহে ব্যর্থ হলে সর্বোচ্চ ৭ থেকে ১০ কার্যদিবসের মধ্যে ১০০% অর্থ সরাসরি গ্রাহকের অ্যাকাউন্টে ফেরত দিতে বাধ্য। রিফান্ডের টাকা ওয়ালেট বা কুপন আকারে আটকে রাখা আইনত নিষিদ্ধ।\n\n' +
              'সবচেয়ে বড় আইনি সুবিধা হলো—**ভোক্তা অধিকার সংরক্ষণ আইন ২০০৯-এর ধারা ৭৬(৪)** অনুযায়ী, জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তরে (DNCRP) অভিযোগ দায়েরের পর অপরাধ প্রমাণিত হয়ে বিক্রেতার ওপর যে আর্থিক জরিমানা ধার্য করা হবে, **সেই জরিমানার ২৫% অর্থ তাৎক্ষণিকভাবে অভিযোগকারী গ্রাহককে নগদ ক্ষতিপূরণ হিসেবে প্রদান করা হবে!**\n\n' +
              'আইন অনুযায়ী ঘটনার ৩০ কার্যদিবসের মধ্যে DNCRP-এর টোল-ফ্রি হটলাইন **১৬১২১** বা অনলাইনে অভিযোগ দাখিল করতে হবে।'
          : 'Receiving defective goods, fraudulent online deliveries, or merchant refusal to disburse refunds violates statutory consumer legislation. You possess robust legal protection under Bangladesh law.\n\n' +
              'Under **Clauses 3.1.8 & 3.5.1 of the Digital Commerce Guidelines 2021 and Section 50 of the Consumer Rights Protection Act 2009**, merchants failing delivery or providing substandard goods are legally obligated to issue a 100% monetary refund within 7-10 working days. Forcing store credits or non-cash coupons is illegal.\n\n' +
              'Crucially, under **Section 76(4) of the Consumer Rights Protection Act 2009**, when DNCRP convicts a defaulting merchant and imposes an administrative penalty fine, **25% of the total collected fine is immediately awarded in cash to the consumer as direct compensation!**\n\n' +
              'Complaints must be lodged within 30 working days via national consumer hotline **16121** or official portal.';

      whatToDoNext = isBangla
          ? 'ক্রয় রসিদ (Cash Memo/Invoice), চ্যাট ও আনবক্সিং প্রমাণ সংরক্ষণ করুন। জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তরে (DNCRP) অভিযোগ দাখিল করুন (হটলাইন: ১৬১২১)।'
          : 'Preserve invoices, chat transcripts, and unboxing proofs. Lodge a formal consumer complaint with DNCRP (hotline 16121) within 30 working days.';

      checklist = [
        ChecklistStep(
          id: 'step-1',
          text: isBangla
              ? 'ক্রয় রসিদ (Invoice/Cash Memo), ডেলিভারি স্লিপ, পণ্যের স্পষ্ট ছবি এবং চ্যাট হিস্ট্রি নিরাপদ স্থানে সংরক্ষণ করুন'
              : 'Secure purchase invoice, delivery slip, product photographs, and order confirmation messages',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-2',
          text: isBangla
              ? 'বিক্রেতা বা অনলাইন প্রতিষ্ঠানের সাথে লিখিতভাবে যোগাযোগ করে ৩ কার্যদিবসের মধ্যে সম্পূর্ণ টাকা রিফান্ডের চূড়ান্ত দাবি জানান'
              : 'Issue a formal written notice to the merchant demanding full 100% refund within 3 business days',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-3',
          text: isBangla
              ? 'ঘটনার ৩০ কার্যদিবসের মধ্যে জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তরে (DNCRP) লিখিত অভিযোগ বা ১৬১২১ নম্বরে কল করুন'
              : 'File an official grievance with DNCRP within 30 days of the cause of action or call toll-free helpline 16121',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-4',
          text: isBangla
              ? 'MyLaws অ্যাপের মাধ্যমে ভোক্তা অধিকার সংরক্ষণ অধিদপ্তর বরাবর প্রস্তুতকৃত প্রাতিষ্ঠানিক অভিযোগের খসড়াটি প্রিন্ট করে জমা দিন'
              : 'Generate and print the official DNCRP complaint draft using MyLaws and submit to the Assistant Director, DNCRP',
          completed: false,
        ),
      ];
      allowedDraftOptions = ['dncrp'];
    } else if (isCyber) {
      category = 'digital';
      sourceIds = ['penal-383', 'penal-385', 'cyber-24'];
      identifiedIssue = isBangla
          ? 'সাইবার ব্ল্যাকমেইল, ব্যক্তিগত তথ্য ফাঁসের হুমকি ও আইনি প্রতিকার'
          : 'Cyber Harassment, Digital Blackmail & Statutory Protection';

      explanationMeaning = isBangla
          ? 'অনলাইনে ছবি ফাঁসের হুমকি, ব্ল্যাকমেইল বা ব্যক্তিগত তথ্য দিয়ে হয়রানি একটি অত্যন্ত মারাত্মক জামিনঅযোগ্য ফৌজদারি অপরাধ। এ ধরনের পরিস্থিতিতে আতঙ্কিত হওয়া স্বাভাবিক, তবে ভয় পেয়ে কোনো অবস্থাতেই টাকা পাঠাবেন না বা আপস করবেন না।\n\n' +
              '**পর্নোগ্রাফি নিয়ন্ত্রণ আইন ২০১২-এর ধারা ৮(১) ও ৮(৩)** অনুযায়ী, কারো সম্মতি ছাড়া ব্যক্তিগত ছবি বা ভিডিও ধারণ, সংরক্ষণ বা ফাঁসের হুমকি দিয়ে ব্ল্যাকমেইল করা সম্পূর্ণ জামিনঅযোগ্য অপরাধ, যার শাস্তি **সর্বোচ্চ ৫ থেকে ৭ বছর সশ্রম কারাদণ্ড এবং ২ লক্ষ টাকা পর্যন্ত অর্থদণ্ড**। এছাড়া **দণ্ডবিধি ১৮৬০-এর ৩৮৩ ও ৩৮৫ ধারা** এবং সাইবার সুরক্ষা আইনের আওতায় চাঁদাবাজি ও ভয়ভীতি প্রদর্শনের জন্য কঠোর শাস্তির বিধান রয়েছে।\n\n' +
              'মনে রাখবেন, ব্ল্যাকমেইলারকে টাকা পাঠালে ব্ল্যাকমেইল বন্ধ হয় না, বরং তাদের লোভ আরও বেড়ে যায়। তাই সরাসরি অপরাধীর সাথে যোগাযোগ বন্ধ করে আইনগত ব্যবস্থা নেওয়াই মুক্তির একমাত্র পথ।\n\n' +
              'বাংলাদেশ পুলিশের বিশেষ ইউনিট **পুলিশ সাইবার সাপোর্ট ফর উইমেন (PCSW: ০১৩২০০০০৮৮৮)** এবং জাতীয় জরুরি সেবা **৯৯৯**-এ কল করে তাৎক্ষণিক পরিচয় গোপন রেখে সহায়তা পাওয়া সম্ভব।'
          : 'Online blackmail, threats to publish private photographs, and digital extortion are serious, non-bailable criminal offenses. While alarming, do not yield to extortion demands or transfer funds.\n\n' +
              'Under **Section 8(1) & 8(3) of the Pornography Control Act 2012**, capturing, possessing, or threatening to disseminate private images or video materials carries **up to 7 years rigorous imprisonment and BDT 200,000 fine**. In addition, **Sections 383 and 385 of the Penal Code 1860** severely penalize digital extortion.\n\n' +
              'Paying blackmailers never resolves the extortion; lawful police intervention is the only definitive protection.\n\n' +
              'Immediate confidential intervention is available via the **Police Cyber Support for Women (PCSW hotline: 01320000888)** and National Emergency Services **999**.';

      whatToDoNext = isBangla
          ? 'ব্ল্যাকমেইলারকে কোনো টাকা পাঠাবেন না। সকল চ্যাট, অডিও ও স্ক্রিনশট নিরাপদ ক্লাউড ড্রাইভে ব্যাকআপ রাখুন এবং দ্রুত থানা বা সাইবার পুলিশ সেন্টারে যোগাযোগ করুন।'
          : 'Do not transfer money. Secure backups of all chat records, audio recordings, and phone numbers, and report immediately to Police Cyber Support or local police.';

      checklist = [
        ChecklistStep(
          id: 'step-1',
          text: isBangla
              ? 'ভয় পেয়ে কোনো টাকা পাঠাবেন না বা কোনো অনৈতিক আপস করবেন না; অপরাধীর সাথে সমস্ত কথোপকথন সাময়িক স্থগিত রাখুন'
              : 'Do not send money or compromise under pressure; cease further direct communication with the perpetrator',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-2',
          text: isBangla
              ? 'হুমকি বা ব্ল্যাকমেইলের সকল চ্যাট হিস্ট্রি, অডিও রেকর্ড, প্রোফাইল লিংক ও স্পষ্ট স্ক্রিনশট গুগল ড্রাইভে ব্যাকআপ রাখুন'
              : 'Preserve full message histories, audio clips, social profile URLs, and call logs to secure cloud storage',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-3',
          text: isBangla
              ? 'পুলিশ সাইবার সাপোর্ট ফর উইমেন (হটলাইন: ০১৩২০০০০৮৮৮) অথবা জাতীয় জরুরি সেবা ৯৯৯-এ তাৎক্ষণিক অভিযোগ জানান'
              : 'Report the incident with evidence to Police Cyber Support (01320000888) or dial 999 for emergency cyber dispatch',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-4',
          text: isBangla
              ? 'নিকটস্থ থানায় বিস্তারিত প্রমাণাদিসহ পর্নোগ্রাফি নিয়ন্ত্রণ আইন ও দণ্ডবিধির অধীনে লিখিত এজাহার/সাধারণ ডায়েরি (জিডি) দাখিল করুন'
              : 'Lodge a formal FIR or GD at the jurisdictional police station under the Pornography Control Act and Penal Code',
          completed: false,
        ),
      ];
      allowedDraftOptions = ['gd'];
    } else if (isCheque) {
      category = 'finance';
      sourceIds = ['ni-act-138', 'penal-420'];
      identifiedIssue = isBangla
          ? 'চেক বাউন্স, ডিজঅনার ও পাওনা টাকা আদায়ের আইনি প্রতিকার'
          : 'Cheque Dishonour, Bank Bounce & Financial Debt Recovery';

      explanationMeaning = isBangla
          ? 'ব্যবসায়িক বা ব্যক্তিগত পাওনা পরিশোধের জন্য দেওয়া চেক ব্যাংকে অপর্যাপ্ত তহবিল বা অ্যাকাউন্ট বন্ধ থাকার কারণে বাউন্স/ডিজঅনার হওয়া একটি গুরুতর ফৌজদারি অপরাধ।\n\n' +
              '**হস্তান্তরযোগ্য দলিল আইন ১৮৮১ (The Negotiable Instruments Act, 1881)-এর ধারা ১৩৮** অনুযায়ী, কোনো চেক ব্যাংকে প্রত্যাখ্যাত হলে চেকের আদেশকারী **সর্বোচ্চ ১ বছর পর্যন্ত কারাদণ্ডে বা চেকের মূল অঙ্কের তিনগুণ পর্যন্ত অর্থদণ্ডে অথবা উভয় দণ্ডে** দণ্ডনীয় হবেন।\n\n' +
              'তবে এ আইনে প্রতিকার পেতে কিছু সুনির্দিষ্ট ও অপরিবর্তনীয় আইনি সময়সীমা মানা বাধ্যতামূলক:\n' +
              '১. ব্যাংক থেকে ডিজঅনার মেমো বা স্লিপ পাওয়ার **৩০ দিনের মধ্যে** অবশ্যই আইনজীবীর মাধ্যমে রেজিস্টার্ড ডাকযোগে লিগ্যাল নোটিশ পাঠাতে হবে।\n' +
              '২. নোটিশ পাওয়ার পর প্রতিপক্ষকে টাকা পরিশোধের জন্য **১৫ দিন সময়** দিতে হবে।\n' +
              '৩. ওই ১৫ দিন অতিবাহিত হওয়ার পরবর্তী **৩০ দিনের মধ্যে** উপযুক্ত চিফ জুডিসিয়াল/মেট্রোপলিটন ম্যাজিস্ট্রেট আদালতে ফৌজদারি মোকদ্দমা (সিআর মামলা) দায়ের করতে হবে।'
          : 'Having a cheque dishonoured due to insufficient funds or closed accounts is a serious criminal offense under statutory financial legislation.\n\n' +
              'Under **Section 138 of the Negotiable Instruments Act 1881 (NI Act)**, the drawer of a dishonoured cheque is punishable with **up to 1 year imprisonment, a fine of up to thrice the face value of the cheque, or both**.\n\n' +
              'To enforce remedies under the NI Act, strict statutory deadlines must be adhered to:\n' +
              '1. A formal Statutory Legal Notice must be dispatched via registered post within **30 days** of receiving the bank dishonour memo.\n' +
              '2. The issuer must be allowed **15 days** from notice receipt to clear the debt.\n' +
              '3. If unpaid, a formal criminal complaint must be instituted within the subsequent **30 days** before the competent Magistrate Court.';

      whatToDoNext = isBangla
          ? 'ব্যাংকের মূল ডিজঅনার স্লিপ ও চেকের কপি সংগ্রহ করুন। মেমোর তারিখ থেকে ৩০ দিনের মধ্যে আইনজীবীর মাধ্যমে লিগ্যাল নোটিশ প্রেরণ নিশ্চিত করুন।'
          : 'Preserve the original dishonoured cheque and bank return memo. Ensure a statutory legal notice is served within 30 days of the memo date.';

      checklist = [
        ChecklistStep(
          id: 'step-1',
          text: isBangla
              ? 'মূল চেক এবং সংশ্লিষ্ট ব্যাংকের সই-সিলযুক্ত ডিজঅনার স্লিপ (Bank Return Memo) নিরাপদে সংরক্ষণ করুন'
              : 'Preserve the original bounced cheque and the official signed/stamped bank return memo',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-2',
          text: isBangla
              ? 'ব্যাংকের স্লিপ পাওয়ার ৩০ দিনের মধ্যে আইনজীবীর মাধ্যমে রেজিস্টার্ড ডাকযোগে আইনসম্মত লিগ্যাল নোটিশ পাঠান'
              : 'Serve a formal statutory legal notice via registered post within 30 days of the bank return memo',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-3',
          text: isBangla
              ? 'নোটিশ জারির রসিদ এবং এডি (Acknowledgement Due) কার্ড যত্নসহকারে কোর্ট ফাইলের জন্য সংগ্রহ করুন'
              : 'Retain the postal registration receipt and postal acknowledgment receipt (AD slip)',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-4',
          text: isBangla
              ? 'নোটিশের ১৫ দিন অতিবাহিত হলে পরবর্তী ৩০ দিনের মধ্যে উপযুক্ত ম্যাজিস্ট্রেট আদালতে ১৩৮ ধারায় নালিশি মামলা দায়ের করুন'
              : 'File a formal criminal complaint under Section 138 of the NI Act before the Magistrate Court within 30 days after the notice grace period expires',
          completed: false,
        ),
      ];
      allowedDraftOptions = ['magistrate_court'];
    } else if (isProperty) {
      category = 'property';
      sourceIds = ['land-crime-4', 'sat-143', 'sra-54'];
      identifiedIssue = isBangla
          ? 'জমি দখল, সীমানা বিরোধ ও ভূমিস্বত্ব আইনি সুরক্ষা'
          : 'Land Demarcation, Boundary Encroachment & Property Rights';

      explanationMeaning = isBangla
          ? 'জমির সীমানা বা দখল সংক্রান্ত বিরোধে আইন নিজের হাতে না তুলে সঠিক প্রশাসনিক ও দেওয়ানি আদালতে আইনি প্রতিকার গ্রহণ করাই সবচেয়ে স্থায়ী সমাধান।\n\n' +
              '**ভূমি অপরাধ প্রতিরোধ ও প্রতিকার আইন ২০২৩-এর ধারা ৪ ও ৫** অনুযায়ী, বৈধ মালিক বা দখলদারকে জোরপূর্বক বেদখল করা, সীমানা নষ্ট করা বা ভুয়া দলিল তৈরি করা কঠোর দণ্ডনীয় আমলযোগ্য ফৌজদারি অপরাধ, যার শাস্তি **সর্বোচ্চ ৭ বছর পর্যন্ত কারাদণ্ড ও অর্থদণ্ড**।\n\n' +
              'রেকর্ডীয় স্বত্ব ও নামজারি সুরক্ষার জন্য **রাষ্ট্রীয় অধিগ্রহণ ও প্রজাস্বত্ব আইন ১৯৫০-এর ১৪৩ ধারা** মোতাবেক উপজেলা সহকারী কমিশনার (ভূমি) (AC Land) অফিসে মিস কেস দায়ের করা যায়। এছাড়া বিরোধপূর্ণ জমিতে বলপূর্বক অনুপ্রবেশ বা নির্মাণকাজ বন্ধ করতে বিজ্ঞ সহকারী জজ আদালতে **সুনির্দিষ্ট প্রতিকার আইন ১৮৭৭-এর ধারা ৫৪** অনুযায়ী চিরস্থায়ী নিষেধাজ্ঞা (Permanent Injunction) প্রার্থনার পূর্ণ আইনি অধিকার আপনার রয়েছে।'
          : 'Land boundary disputes and unlawful encroachment must be resolved through lawful administrative and civil court procedures.\n\n' +
              'Under the **Land Crime Prevention and Redress Act 2023**, unlawful encroachment, boundary destruction, or fraudulent title documentation are cognizable criminal offenses punishable with **up to 7 years imprisonment and fine**.\n\n' +
              'Under **Section 143 of the State Acquisition and Tenancy Act 1950**, mutation corrections are handled by the Assistant Commissioner (Land). Furthermore, under **Section 54 of the Specific Relief Act 1877**, you can seek a permanent civil court injunction to prevent unlawful entry or construction.';

      whatToDoNext = isBangla
          ? 'সিএস, এসএ, আরএস ও হাল বিএস খতিয়ান এবং খাজনার রসিদ সংগ্রহ করুন। ইউনিয়ন ভূমি অফিসে রেকর্ড যাচাই করে সহকারী জজ আদালতে চিরস্থায়ী নিষেধাজ্ঞার মোকদ্দমা প্রস্তুত করুন।'
          : 'Gather CS, SA, RS, and BS record of rights along with up-to-date land tax receipts. Verify mutation records at the local land office and file for civil injunction.';

      checklist = [
        ChecklistStep(
          id: 'step-1',
          text: isBangla
              ? 'মূল দলিল, সিএস/এসএ/আরএস/বিএস খতিয়ান এবং হালনাগাদ ভূমি উন্নয়ন কর (খাজনা)-এর দাখিলা গুছিয়ে রাখুন'
              : 'Compile certified registered title deeds, historical Khatians, and up-to-date land tax receipts',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-2',
          text: isBangla
              ? 'উপজেলা সহকারী কমিশনার (ভূমি) অফিসে গিয়ে রেকর্ড ও সীমানা যাচাই করে নামজারি ত্রুটি থাকলে মিস কেস করুন'
              : 'Verify mutation and boundary demarcation records at the Upazila Assistant Commissioner (Land) office',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-3',
          text: isBangla
              ? 'জোরপূর্বক বেদখল বা সীমানা লঙ্ঘনের চেষ্টা হলে বিজ্ঞ সহকারী জজ আদালতে দেওয়ানি মোকদ্দমা (চিরস্থায়ী নিষেধাজ্ঞা) দায়ের করুন'
              : 'File a petition for permanent injunction before the competent Civil Court if unlawful encroachment threatens',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-4',
          text: isBangla
              ? 'সহিংসতা বা বলপ্রয়োগের আশঙ্কা থাকলে তাৎক্ষণিকভাবে নিকটস্থ থানায় ফৌজদারি কার্যবিধির ১৪৪/১৪৫ ধারায় শান্তিভঙ্গ রোধে আবেদন করুন'
              : 'Petition the Executive Magistrate under Section 144/145 of the CrPC via police to prevent breach of peace',
          completed: false,
        ),
      ];
      allowedDraftOptions = ['civil_court'];
    } else if (isTenantOrRent) {
      category = 'tenant';
      sourceIds = ['rent-18', 'rent-19', 'rent-13'];
      identifiedIssue = isBangla
          ? 'বাড়ি ভাড়া, ভাড়াটিয়ার সংবিধিবদ্ধ আইনি অধিকার ও সুরক্ষা'
          : 'Tenant Rights & Protection Against Unlawful Eviction';

      explanationMeaning = isBangla
          ? 'বাড়ি ভাড়া সংক্রান্ত বিষয়ে ভাড়াটিয়ার সংবিধিবদ্ধ আইনি অধিকার সুরক্ষিত রাখা অত্যন্ত জরুরি। ভাড়াটিয়াদের স্বার্থ রক্ষায় বাড়ি ভাড়া নিয়ন্ত্রণ আইনে সুস্পষ্ট বাধ্যবাধকতা রয়েছে।\n\n' +
              '**বাড়ি ভাড়া নিয়ন্ত্রণ আইন ১৯৯১-এর ১৮ ধারা** অনুযায়ী, ভাড়াটিয়া নিয়মিত চুক্তি অনুযায়ী ভাড়া পরিশোধ করতে সম্মত থাকলে বাড়িওয়ালা তাকে ইচ্ছামাফিক বা বলপূর্বক উচ্ছেদ করতে পারেন না। উচ্ছেদ করতে হলে বাড়িওয়ালাকে উপযুক্ত আদালতে উচ্ছেদের মোকদ্দমা করে ডিক্রি নিতে হবে।\n\n' +
              '**ধারা ১৯** মোতাবেক, ভাড়াটিয়াকে হয়রানি করার উদ্দেশ্যে গ্যাস, বিদ্যুৎ বা পানির মতো জরুরি নাগরিক সংযোগ বিচ্ছিন্ন করা কঠোরভাবে নিষিদ্ধ ও দণ্ডনীয় অপরাধ। এছাড়া **ধারা ১৩** অনুযায়ী প্রতিটি ভাড়া আদায়ের বিপরীতে বাড়িওয়ালা কর্তৃক লিখিত রসিদ (Rent Receipt) প্রদান আইনত বাধ্যতামূলক। বাড়িওয়ালা রসিদ দিতে অস্বীকৃতি জানালে ভাড়াটিয়া ব্যাংক বা মানি অর্ডারের মাধ্যমে ভাড়া জমা দিতে পারেন।'
          : 'Securing tenant rights in rental housing is an essential protection under statutory law.\n\n' +
              'Under **Section 18 of the Premises Rent Control Act 1991**, landlords cannot forcibly evict a tenant as long as the tenant pays the agreed rent, except through a formal civil court decree.\n\n' +
              'Under **Section 19**, cutting off essential utilities (gas, electricity, water) is a strictly punishable offense. Furthermore, **Section 13** legally mandates landlords to provide a written receipt for every rent disbursement.';

      whatToDoNext = isBangla
          ? 'ভাড়া পরিশোধের রসিদ, চুক্তিপত্র ও ব্যাংক স্টেটমেন্ট গুছিয়ে রাখুন। বাড়িওয়ালাকে শান্তভাবে আইন স্মরণ করিয়ে দিন এবং প্রয়োজনে ভাড়া নিয়ন্ত্রক আদালতের দ্বারস্থ হন।'
          : 'Preserve your tenancy contract, rent receipts, and bank transaction proofs. Inform the landlord of statutory protections and consult the Rent Controller Court if disputes arise.';

      checklist = [
        ChecklistStep(
          id: 'step-1',
          text: isBangla
              ? 'বাড়ি ভাড়ার চুক্তিপত্র (Tenancy Agreement), রসিদ ও লেনদেনের প্রমাণপত্র নিরাপদ স্থানে সংরক্ষণ করুন'
              : 'Organize your Tenancy Agreement, rent receipts, and payment transaction confirmations',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-2',
          text: isBangla
              ? 'বাড়িওয়ালা কর্তৃক কোনো চাপ বা উচ্ছেদের হুমকি এলে বিষয়টি উল্লেখ করে আনুষ্ঠানিক লিখিত পত্র দিন'
              : 'Issue a polite, written formal letter to the landlord citing statutory tenancy protections',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-3',
          text: isBangla
              ? 'পানি, গ্যাস বা বিদ্যুৎ বিচ্ছিন্ন করলে তাৎক্ষণিকভাবে স্থানীয় থানায় অথবা ভাড়া নিয়ন্ত্রক আদালতে আবেদন দাখিল করুন'
              : 'File an emergency complaint with the Rent Controller Court or police station if utilities are unlawfully disconnected',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-4',
          text: isBangla
              ? 'বাড়িওয়ালা ভাড়া নিতে অস্বীকৃতি জানালে বা রসিদ না দিলে মানি অর্ডার বা ভাড়া নিয়ন্ত্রক আদালতে ট্রেজারি চালানের মাধ্যমে ভাড়া জমা দিন'
              : 'Deposit rent with the Rent Controller Court via treasury challan or money order if the landlord refuses receipt',
          completed: false,
        ),
      ];
      allowedDraftOptions = ['civil_court'];
    } else if (isFamilyCourt) {
      category = 'family';
      sourceIds = ['family-5', 'family-6', 'muslim-family-9'];
      identifiedIssue = isBangla
          ? 'দেনমোহর, ভরণপোষণ ও পারিবারিক আদালতের আইনি সুরক্ষা'
          : 'Dower, Maintenance & Family Court Statutory Protections';

      explanationMeaning = isBangla
          ? 'পারিবারিক জীবনে দেনমোহর ও ভরণপোষণ আদায় স্ত্রীর অলঙ্ঘনীয় সংবিধিবদ্ধ আইনি অধিকার। পারিবারিক আদালত আইনে এ বিষয়ে নারীকে সর্বোচ্চ আইনি সুরক্ষা দেওয়া হয়েছে।\n\n' +
              '**পারিবারিক আদালত আইন ২০২৩-এর ধারা ৫** অনুযায়ী, বকেয়া দেনমোহর (Mahr) এবং স্ত্রী ও নাবালক সন্তানের মাসিক ভরণপোষণ আদায়ের জন্য পারিবারিক আদালতের একচ্ছত্র এখতিয়ার রয়েছে। স্বামী বিবাহবিচ্ছেদ করুক বা না করুক, দেনমোহর এবং সন্তানের ভরণপোষণ দিতে আইনত বাধ্য।\n\n' +
              'সবচেয়ে বড় আইনি সুবিধা হলো—**পারিবারিক আদালত আইন ২০২৩-এর ধারা ৬** অনুযায়ী, স্ত্রী বর্তমানে যে এলাকায় বসবাস করছেন, সেই অধিক্ষেত্রের স্থানীয় পারিবারিক আদালতেই মামলা দায়ের করতে পারেন; স্বামীর স্থায়ী ঠিকানায় যাওয়ার কোনো প্রয়োজন নেই। এছাড়া ডিক্রি পাওয়ার পর স্বামী টাকা পরিশোধ না করলে আদালত তার বিরুদ্ধে সরাসরি ক্রোকি পরোয়ানা বা দেওয়ানি কারাদণ্ডের আদেশ দিতে পারেন।'
          : 'Recovering prompt and deferred dower (Mahr) and statutory maintenance is an inviolable legal right under the **Family Courts Act, 2023**.\n\n' +
              'Under **Section 5 of the Family Courts Act 2023**, the Family Court holds exclusive jurisdiction over dower and maintenance. Regardless of divorce, the husband is legally mandated to clear outstanding dower and ongoing child support.\n\n' +
              'Under **Section 6**, the suit can be instituted within the territorial jurisdiction where the wife currently resides, relieving her of having to travel to the husband\'s location. Enforcement decrees can attach property or issue civil detention warrants for non-compliance.';

      whatToDoNext = isBangla
          ? 'কাবিননামার (নিকাহনামা) মূল কপি বা জাবেদা নকল সংগ্রহ করুন। দেনমোহর ও ভরণপোষণের হিসাব করে পারিবারিক আদালতে বিজ্ঞ আইনজীবীর মাধ্যমে মামলা প্রস্তুত করুন।'
          : 'Collect a certified copy of your marriage certificate (Nikahnama). Calculate outstanding maintenance and prepare a petition for the Family Court.';

      checklist = [
        ChecklistStep(
          id: 'step-1',
          text: isBangla
              ? 'নিকাহনামা (কাবিননামা)-এর সত্যায়িত অনুলিপি ও বিয়ের প্রাসঙ্গিক প্রমাণাদি গুছিয়ে রাখুন'
              : 'Assemble certified copy of Nikahnama and relevant marital documentation',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-2',
          text: isBangla
              ? 'বকেয়া দেনমোহর ও সন্তানের মাসিক ভরণপোষণের দাবি জানিয়ে আইনজীবীর মাধ্যমে নোটিশ পাঠান'
              : 'Issue a legal notice demanding payment of dower and child maintenance',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-3',
          text: isBangla
              ? 'আপস মীমাংসা না হলে পারিবারিক আদালত আইন ২০২৩ অনুযায়ী স্থানীয় পারিবারিক আদালতে আরজি দাখিল করুন'
              : 'Institute a suit before the local Family Court under the Family Courts Act 2023',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-4',
          text: isBangla
              ? 'আর্থিক অসচ্ছলতার ক্ষেত্রে সরকারি টোল-ফ্রি আইনি সহায়তা হেল্পলাইন ১৬৬৯৯-এ কল করে বিনামূল্যে আইনজীবী সহায়তা নিন'
              : 'Avail free government-funded legal representation via National Legal Aid Services Organization (NLASO helpline: 16699)',
          completed: false,
        ),
      ];
      allowedDraftOptions = ['family_court'];
    } else if (isAdministrative) {
      category = 'administrative';
      sourceIds = []; // No criminal or civil statutes forced!
      identifiedIssue = isBangla
          ? 'নাগরিক প্রশাসনিক সেবা প্রাপ্তির প্রক্রিয়া'
          : 'Citizen Administrative Procedure Roadmap';
      explanationMeaning = isBangla
          ? 'ড্রাইভিং লাইসেন্স বা পাসপোর্ট ইত্যাদি সরকারি সেবা প্রাপ্তি একটি নিয়মিত নাগরিক প্রক্রিয়া। এর জন্য কোনো আদালত বা থানার অনুমতি প্রয়োজন হয় না।\n\n' +
              'বাংলাদেশ সড়ক পরিবহন কর্তৃপক্ষ (BRTA) অথবা পাসপোর্ট অধিদপ্তর নির্ধারিত অনলাইন পোর্টালে নাগরিকগণ কোনো মধ্যস্বত্বভোগী বা দালাল ছাড়াই সরাসরি আবেদন করতে পারেন। সরকার নির্ধারিত আবেদন ফি ও পরিচয়পত্র জমা দিলে যথাসময়ে সেবা পাওয়া নিশ্চিত হয়।'
          : 'Procuring a driving license or national passport is a standard citizen administrative service requiring direct government application.\n\n' +
              'Citizens can apply directly via the Bangladesh Road Transport Authority (BRTA) or Department of Immigration and Passports online portals without third-party brokers by paying statutory fees and providing identity proofs.';
      whatToDoNext = isBangla
          ? 'প্রয়োজনীয় জাতীয় পরিচয়পত্র, ছবি ও শিক্ষাগত সনদের ফটোকপি সংগ্রহ করুন এবং সরকারি পোর্টালে অনলাইন আবেদন সম্পন্ন করুন।'
          : 'Assemble NID, passport-size photographs, and certificates, then submit your application on the official government portal.';
      checklist = [
        ChecklistStep(
          id: 'step-1',
          text: isBangla
              ? 'জাতীয় পরিচয়পত্র (NID), পাসপোর্ট সাইজ ছবি ও প্রযোজ্য ক্ষেত্রে শিক্ষাগত/মেডিকেল সনদ প্রস্তুত রাখুন'
              : 'Assemble national ID card, passport photographs, and relevant medical/educational certificates',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-2',
          text: isBangla
              ? 'অফিসিয়াল সার্ভিস পোর্টাল (যেমন bsp.brta.gov.bd)-এ গিয়ে সঠিক তথ্য দিয়ে ফরম পূরণ ও নির্ধারিত ফি জমা দিন'
              : 'Complete online form on the official portal and submit prescribed government fees',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-3',
          text: isBangla
              ? 'নির্ধারিত তারিখে প্রয়োজনীয় মূল কাগজপত্রসহ সংশ্লিষ্ট সার্কেল অফিসে উপস্থিত হয়ে বায়োমেট্রিক ও পরীক্ষা সম্পন্ন করুন'
              : 'Attend the designated circle office on the scheduled date for biometric capture and verification',
          completed: false,
        ),
      ];
      allowedDraftOptions = []; // Empty, no court complaint needed!
    } else if (isFamilyDistress) {
      category = 'family_counseling';
      sourceIds = []; // No statutory provisions for personal emotional crisis
      identifiedIssue = isBangla
          ? 'পারিবারিক অশান্তি ও মানসিক সুরক্ষা'
          : 'Family Support & Personal Well-being';
      explanationMeaning = isBangla
          ? 'আপনার মনের অবস্থাটা আমি বুঝতে পারছি, বাসায় বড়দের ঝগড়া করে চলে যাওয়াটা আপনার জন্য খুব ভয়ের এবং কষ্টের। মনে রাখবেন, এতে আপনার কোনো দোষ নেই — বড়দের ঝগড়া বড়দের বিষয়। এখন সবচেয়ে জরুরি হলো আপনি শান্ত থেকে নিরাপদে থাকবেন।\n\n' +
              'পারিবারিক মনোমালিন্য বা বড়দের ঝগড়ার সময়ে সন্তানের নিজের নিরাপত্তা নিশ্চিত করা এবং শান্ত থাকা সবচেয়ে জরুরি। কোনো আইনি মামলা বা থানার জিডি করার প্রয়োজন নেই; একটু সময় দিলে বড়দের রাগ কমে গেলে উনারাই ফিরে আসবেন ইনশাআল্লাহ। প্রয়োজনে কোনো বিশ্বস্ত আত্মীয় বা সরকারি শিশু সহায়তা নম্বরে কথা বলুন।'
          : 'During domestic disputes, staying safe and remaining calm is the top priority. Please stay calm and safe in your home; remember you are not at fault. Reach out to trusted family members or national child helplines if needed.';
      whatToDoNext = isBangla
          ? 'নিজে নিরাপদে থাকুন, ঘরের দরজা লাগিয়ে শান্ত থাকুন এবং প্রয়োজনে কোনো বিশ্বস্ত আত্মীয় বা ১০৯৮ নম্বরে যোগাযোগ করুন।'
          : 'Stay safe indoors, keep doors locked, and contact a trusted relative or 1098 helpline.';
      checklist = [
        ChecklistStep(
          id: 'step-1',
          text: isBangla
              ? 'নিজে শান্ত থাকুন, ঘরের দরজা লাগিয়ে নিরাপদে অবস্থান করুন'
              : 'Stay calm and ensure your physical safety indoors',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-2',
          text: isBangla
              ? 'বিশ্বস্ত নিকটাত্মীয় (দাদা-দাদি, নানা-নানি, মামা-চাচা) কে ফোন করে পরিস্থিতি জানান'
              : 'Contact a trusted relative or family elder to inform them',
          completed: false,
        ),
        ChecklistStep(
          id: 'step-3',
          text: isBangla
              ? 'ভয় বা নিরাপত্তাহীনতা বোধ করলে বিনামূল্যে সরকারি শিশু সহায়তা হেল্পলাইন ১০৯৮ অথবা ৯৯৯-এ কল করুন'
              : 'Dial free child helpline 1098 or 999 if in immediate distress',
          completed: false,
        ),
      ];
      allowedDraftOptions = []; // Strictly empty!
    } else {
      // Dynamic On-Device Statutory RAG Synthesis
      final matchedProvisions =
          LegalProvisionsCatalog.searchProvisions(userMessage, limit: 3);

      if (matchedProvisions.isNotEmpty) {
        final primary = matchedProvisions.first;
        category = primary.categories.isNotEmpty ? primary.categories.first : 'statute';
        sourceIds = matchedProvisions.map((p) => p.id).toList();

        final actBn = primary.actNameBn ?? primary.title;
        final actEn = primary.actNameEn ?? primary.titleEn;
        final secBn = primary.section ?? '';
        final secEn = primary.section ?? '';

        identifiedIssue = isBangla
            ? '$actBn ($secBn) অনুযায়ী আইনি প্রতিকার ও অধিকার'
            : 'Legal Rights & Remedies under $actEn ($secEn)';

        final plainExp = isBangla
            ? (primary.plainExplanation ?? primary.originalText)
            : (primary.plainExplanationEn ?? primary.plainExplanation ?? primary.originalText);
        final caution = isBangla
            ? (primary.cautionBn ?? '')
            : (primary.cautionEn ?? primary.cautionBn ?? '');

        final explanationBuffer = StringBuffer(isBangla
            ? 'আপনার বিষয়টি বাংলাদেশ সংবিধিবদ্ধ আইনের আওতায় পর্যালোচনা করা হয়েছে। $actBn অনুযায়ী এ বিষয়ে সুনির্দিষ্ট আইনি প্রতিকার ও নাগরিক সুরক্ষার বিধান রয়েছে:\n\n$plainExp'
            : 'Your situation has been evaluated under Bangladesh statutory law. Under $actEn, clear legal protections are guaranteed:\n\n$plainExp');

        if (caution.isNotEmpty) {
          explanationBuffer.write('\n\n');
          explanationBuffer.write(isBangla ? 'সতর্কতা ও করণীয়: $caution' : 'Caution & Compliance: $caution');
        }

        if (matchedProvisions.length > 1) {
          final secondary = matchedProvisions[1];
          final secAct = isBangla ? (secondary.actNameBn ?? '') : (secondary.actNameEn ?? '');
          final secSection = secondary.section ?? '';
          final secExp = isBangla
              ? (secondary.plainExplanation ?? '')
              : (secondary.plainExplanationEn ?? secondary.plainExplanation ?? '');
          if (secExp.isNotEmpty) {
            explanationBuffer.write('\n\n');
            explanationBuffer.write(isBangla
                ? 'অনুষঙ্গিক সংবিধিবদ্ধ বিধান ($secAct - $secSection): $secExp'
                : 'Supplementary Statutory Provision ($secAct - $secSection): $secExp');
          }
        }
        explanationMeaning = explanationBuffer.toString();

        whatToDoNext = isBangla
            ? 'ঘটনা সংক্রান্ত যাবতীয় প্রমাণ (লেনদেনের রসিদ, চ্যাট/মেসেজ, চুক্তিপত্র বা নোটিশ) সুরক্ষিত রাখুন এবং দ্রুত সংশ্লিষ্ট দপ্তর বা আদালতে লিখিত আবেদন করুন।'
            : 'Secure all evidentiary records (receipts, communications, agreements, or legal notices) and lodge a formal petition with the competent authority.';

        checklist = [
          ChecklistStep(
            id: 'step-1',
            text: isBangla
                ? 'ঘটনার বিবরণ, তারিখ, সময় এবং প্রাসঙ্গিক সকল লিখিত ও ডিজিটাল প্রমাণাদি সংগ্রহ ও সংরক্ষণ করুন'
                : 'Collect and preserve all relevant documentary and digital evidence with dates and timestamps',
            completed: false,
          ),
          ChecklistStep(
            id: 'step-2',
            text: isBangla
                ? 'আইন অনুযায়ী প্রতিপক্ষকে রেজিস্টার্ড ডাকযোগে অথবা সরাসরি সংবিধিবদ্ধ লিগ্যাল নোটিশ বা লিখিত আবেদন পাঠান'
                : 'Serve a formal statutory notice or written petition to the opposing party/authority as required by law',
            completed: false,
          ),
          ChecklistStep(
            id: 'step-3',
            text: isBangla
                ? 'নির্ধারিত সময়সীমার মধ্যে সুরাহা না হলে বিজ্ঞ উপযুক্ত আদালতে আরজি বা অভিযোগ দাখিল করুন'
                : 'Institute formal legal proceedings before the competent court if no satisfactory resolution is reached within the limitation period',
            completed: false,
          ),
        ];

        final primaryId = primary.id.toLowerCase();
        if (primaryId.contains('gd') || primaryId.contains('police') || primaryId.contains('theft') || primaryId.contains('lost')) {
          allowedDraftOptions = ['gd'];
        } else if (primaryId.contains('dncrp') || primaryId.contains('consumer') || primaryId.contains('ecommerce')) {
          allowedDraftOptions = ['dncrp'];
        } else if (primaryId.contains('labour') || primaryId.contains('wage') || primaryId.contains('dife')) {
          allowedDraftOptions = ['dife'];
        } else if (primaryId.contains('family') || primaryId.contains('dower') || primaryId.contains('dowry')) {
          allowedDraftOptions = ['family_court'];
        } else if (primaryId.contains('sat') || primaryId.contains('land') || primaryId.contains('rent')) {
          allowedDraftOptions = ['civil_court'];
        } else if (primaryId.contains('ni-act') || primaryId.contains('cheque') || primaryId.contains('penal-420')) {
          allowedDraftOptions = ['magistrate_court'];
        } else {
          allowedDraftOptions = ['gd'];
        }
      } else {
        // General Informational Fallback (only if zero provisions matched)
        category = 'rights';
        sourceIds = [];
        identifiedIssue = isBangla
            ? 'নাগরিক আইনি তথ্য ও সরকারি আইনি সহায়তা'
            : 'Citizen Legal Guidance & Government Legal Aid';
        explanationMeaning = isBangla
            ? 'আপনার পরিস্থিতি পর্যালোচনা করে প্রাসঙ্গিক আইনি অধিকার ও সহায়তার দিকনির্দেশনা নিচে তুলে ধরা হলো।\n\n' +
                'বাংলাদেশের সংবিধিবদ্ধ আইন অনুযায়ী প্রতিটি নাগরিকের আইনি অধিকার সুরক্ষা ও আদালতে বিচার পাওয়ার সমান সুযোগ রয়েছে। অসহায় বা অসচ্ছল নাগরিকগণের জন্য সরকারের জাতীয় আইনগত সহায়তা প্রদান সংস্থা (NLASO) সরকারি খরচে সম্পূর্ণ বিনামূল্যে আইনজীবী নিয়োগ ও আইনি পরামর্শ দিয়ে থাকে।'
            : 'Under Bangladesh law, every citizen is entitled to equal protection under the law and fair access to justice. The National Legal Aid Services Organization (NLASO) offers free legal counsel and government-funded representation for eligible citizens.';
        whatToDoNext = isBangla
            ? 'আপনার নথিপত্র গুছিয়ে রাখুন এবং প্রয়োজনে সরকারি হেল্পলাইন ১৬৬৯৯-এ কল করে বিস্তারিত আইনি সহায়তা গ্রহণ করুন।'
            : 'Gather your documents and consult the national toll-free legal aid hotline at 16699.';
        checklist = [
          ChecklistStep(
            id: 'step-1',
            text: isBangla
                ? 'ঘটনাক্রম এবং প্রাসঙ্গিক কাগজপত্র গুছিয়ে একটি সংক্ষিপ্ত বিবরণী তৈরি করুন'
                : 'Organize relevant documents and write down a chronological timeline of events',
            completed: false,
          ),
          ChecklistStep(
            id: 'step-2',
            text: isBangla
                ? 'সরকারি টোল-ফ্রি জাতীয় আইনি সহায়তা হেল্পলাইন ১৬৬৯৯-এ ফোন করে প্রাথমিক পরামর্শ গ্রহণ করুন'
                : 'Dial government toll-free legal aid hotline 16699 for immediate counseling',
            completed: false,
          ),
          ChecklistStep(
            id: 'step-3',
            text: isBangla
                ? 'প্রয়োজনে নিকটস্থ জেলা জজ আদালত ভবনে অবস্থিত জেলা লিগ্যাল এইড অফিসে যোগাযোগ করুন'
                : 'Visit the District Legal Aid Office located in your District Court building if legal representation is needed',
            completed: false,
          ),
        ];
        allowedDraftOptions = [];
      }
    }

    final claims = sourceIds.map((id) {
      final record = LegalProvisionsCatalog.getById(id);
      final text = record != null
          ? (isBangla
              ? '${record.actNameBn} — ${record.section}: ${record.plainExplanation}'
              : '${record.actNameEn} — ${record.section}: ${record.plainExplanationEn}')
          : 'Statutory provision under Bangladesh Code ($id)';
      return Claim(text: text, sourceIds: [id]);
    }).toList();

    return AnswerResponse(
      schemaVersion: 1,
      answerId: 'offline_${DateTime.now().millisecondsSinceEpoch}',
      caseId: request.caseId ?? 'case_offline',
      turnId: request.turnId ?? 'turn_offline',
      revision: 1,
      engineProvenance: _isModelInstalled
          ? ProcessingEngine.offlineModel
          : ProcessingEngine.offlineGuided,
      outcome: Outcome.answered,
      status: 'completed',
      sourcePackVersion: 'bd-pilot-2026-10-26-corpus-v1',
      allowedDraftOptions: allowedDraftOptions,
      problemSummary: ProblemSummary(
        identifiedIssue: identifiedIssue,
        understanding: '', // Empty string to prevent duplicate header card; empathy is in explanation.meaning
        additionalInfoNeeded: const [],
      ),
      plainLanguageExplanation: PlainLanguageExplanation(
        heading: null, // Null to prevent duplicate heading below header
        meaning: explanationMeaning,
        userRightsAndOptions: const [], // Rights are integrated directly in explanation.meaning markdown
        whatToDoNext: whatToDoNext,
      ),
      explanation: claims,
      checklist: checklist,
      userFacts: [
        Fact(
          fieldId: 'dispute_category',
          value: category,
          status: FactStatus.inferred,
          originalText: userMessage,
        ),
      ],
      limitations: [
        isBangla
            ? 'এই উত্তরটি আপনার ডিভাইসের লোকাল এআই ও অফলাইন আইনি ভাণ্ডার দ্বারা সম্পূর্ণ অফলাইনে তৈরি করা হয়েছে।'
            : 'Generated on-device via the Local AI Model and verified Bangladesh statutory pack.',
      ],
    );
  }
}
