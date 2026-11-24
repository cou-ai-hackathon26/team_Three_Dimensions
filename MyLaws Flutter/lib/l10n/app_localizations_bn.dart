// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'MyLaws';

  @override
  String get appSubtitle =>
      'বাংলাদেশের আইনি তথ্য ও খসড়া প্রস্তুতিতে সাহায্যকারী';

  @override
  String get homeGreeting => 'কী হয়েছে বলুন';

  @override
  String get homeSupporting =>
      'আপনার কথায় ঘটনাটা লিখুন। সহজ ভাষায় পরের ধাপ বুঝতে সাহায্য করব।';

  @override
  String get composerHint => 'আপনার আইনি প্রশ্ন বা সমস্যা এখানে লিখুন...';

  @override
  String get send => 'পাঠান';

  @override
  String get stop => 'থামান';

  @override
  String get retry => 'পুনরায় চেষ্টা';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String characterLimit(int count, int limit) {
    return '$count / $limit';
  }

  @override
  String get signIn => 'সাইন ইন';

  @override
  String get signUp => 'নতুন অ্যাকাউন্ট তৈরি';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get continueWithGoogle => 'গুগল দিয়ে এগিয়ে যান';

  @override
  String get continueAsGuest => 'অ্যাকাউন্ট ছাড়াই চালিয়ে যান';

  @override
  String get guestNotice =>
      'অতিথি মোড: অনলাইন সহকারী বন্ধ থাকবে। তবে ফোনে ইনস্টল করা আইন ভাণ্ডার, স্থানীয় খসড়া ও অফলাইন গাইড সম্পূর্ণ চলবে।';

  @override
  String get email => 'ইমেইল ঠিকানা';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String get modeOnline => 'অনলাইন সহকারী';

  @override
  String get modeOnlineGuided => 'অনলাইন নির্দেশিকা';

  @override
  String get modeOfflineInstalled => 'অফলাইন: আইন ভাণ্ডার সক্রিয়';

  @override
  String get modeOfflineUnavailable => 'অফলাইন: আইন ভাণ্ডার প্রয়োজন';

  @override
  String get modeSample => 'নমুনা মোড (Dev)';

  @override
  String quotaRemaining(int remaining, int limit) {
    return 'আজ আর $remainingটি প্রশ্ন বাকি (মোট $limitটি)';
  }

  @override
  String get quotaExhausted =>
      'আজকের অনলাইন প্রশ্নের সীমা শেষ হয়েছে। ইনস্টল করা আইনের তথ্য ও খসড়া আগের মতোই ব্যবহার করতে পারবেন।';

  @override
  String get quotaUnknown => 'কোটা: অজানা (অফলাইন/অতিথি)';

  @override
  String get sources => 'আইনি উৎসসমূহ';

  @override
  String sourcesCount(int count) {
    return '$countটি ধারা উল্লেখিত';
  }

  @override
  String get sourceVerified => 'কার্যকর আইন';

  @override
  String get sourceMachineChecked =>
      'যন্ত্রের মাধ্যমে যাচাইকৃত, আইনজীবীর পর্যালোচনা নয়';

  @override
  String get viewOriginalLaw => 'মূল আইনের ধারা দেখুন';

  @override
  String get openOfficialLink => 'সরকারি BDLaws পোর্টালে দেখুন';

  @override
  String get checklist => 'করণীয় পদক্ষেপের তালিকা';

  @override
  String get requiredDocuments => 'প্রয়োজনীয় কাগজপত্র';

  @override
  String get helpfulEvidence => 'সহায়ক প্রমাণাদি';

  @override
  String get undo => 'পূর্বাবস্থায় ফেরান';

  @override
  String get stepRecheck => 'তথ্য পরিবর্তনের পর পুনরায় যাচাই প্রয়োজন';

  @override
  String get drafts => 'আইনি খসড়া';

  @override
  String get prepareDraft => 'খসড়া প্রস্তুত করুন';

  @override
  String get draftNotice =>
      'এটি শুধু প্রস্তুতির খসড়া। এটি কোনো আদালত বা সরকারি দপ্তরে দাখিল করা হয়নি।';

  @override
  String get incompleteDraft => 'অসম্পূর্ণ খসড়া · আরো তথ্য প্রয়োজন';

  @override
  String get readyDraft => 'খসড়া প্রস্তুত · পর্যালোচিত';

  @override
  String get reviewCheckbox =>
      'আমি সকল তথ্য, তারিখ ও প্রাপকের নাম সতর্কতার সাথে পড়ে যাচাই করেছি।';

  @override
  String get copyText => 'লেখা কপি করুন';

  @override
  String get savePdf => 'পিডিএফ সংরক্ষণ';

  @override
  String get sharePdf => 'পিডিএফ শেয়ার';

  @override
  String get print => 'প্রিন্ট করুন';

  @override
  String get downloads => 'ডাউনলোড ও অফলাইন';

  @override
  String get legalPack => 'আইনি তথ্যের ভাণ্ডার';

  @override
  String get legalPackDesc =>
      'ইন্টারনেট ছাড়াই আইনের ধারা দেখতে ও যাচাই করতে অফলাইন আইন প্যাক ডাউনলোড করুন।';

  @override
  String get localModel => 'অফলাইন এআই মডেল (ঐচ্ছিক)';

  @override
  String get localModelDesc =>
      'ইন্টারনেট ছাড়া ফোনে এআই চালাতে ব্যবহার হয়। ৪ জিবি+ র‍্যামের উপযুক্ত অ্যান্ড্রয়েড ফোন প্রয়োজন।';

  @override
  String installedVersion(String version) {
    return 'ইনস্টল করা সংস্করণ: $version';
  }

  @override
  String get checkForUpdates => 'আপডেট পরীক্ষা করুন';

  @override
  String get removePack => 'প্যাক মুছে ফেলুন';

  @override
  String get settings => 'সেটিংস';

  @override
  String get appearance => 'অ্যাপের রূপ';

  @override
  String get themeSystem => 'সিস্টেমের মতো';

  @override
  String get themeLight => 'হালকা (লাইট)';

  @override
  String get themeDark => 'গাঢ় (ডার্ক)';

  @override
  String get language => 'ভাষা';

  @override
  String get largerText => 'বড় আকারের লেখা';

  @override
  String get wifiOnly => 'শুধু ওয়াইফাই-তে ডাউনলোড করুন';

  @override
  String get autoUpdate => 'আইন ভাণ্ডার স্বয়ংক্রিয় আপডেট';

  @override
  String get preferOffline => 'অফলাইনে কাজ অগ্রাধিকার দিন';

  @override
  String get privacy => 'গোপনীয়তা ও তথ্য';

  @override
  String get cloudProcessing => 'ক্লাউডে এআই বিশ্লেষণের অনুমতি';

  @override
  String get cloudHistory => 'কথোপকথন ক্লাউডে সেভ করুন';

  @override
  String get hideContentSwitcher => 'অ্যাপ সুইচারে তথ্য আড়াল করুন';

  @override
  String get deleteConversations => 'ফোনে সংরক্ষিত আলাপ মুছুন';

  @override
  String get deleteDrafts => 'ফোনে সংরক্ষিত খসড়া মুছুন';

  @override
  String get deleteAllLocal => 'ফোনের সকল স্থানীয় তথ্য মুছুন';

  @override
  String get deleteCloudHistory => 'ক্লাউডের ইতিহাস মুছুন';

  @override
  String get deleteAccount => 'অ্যাকাউন্ট স্থায়ীভাবে মুছুন';

  @override
  String get about => 'MyLaws সম্পর্কে ও সতর্কতা';

  @override
  String get disclaimerText =>
      'MyLaws সাধারণ মানুষকে আইনি তথ্য বুঝতে ও আবেদনপত্র প্রস্তুত করতে সহায়তা করে। এটি আইনজীবী নয় এবং কোনো সরকারি কর্তৃপক্ষ নয়। এটি আপনার পক্ষে কোনো আবেদন জমা দেয় না।';

  @override
  String get licenses => 'মুক্ত উৎসের লাইসেন্সসমূহ';

  @override
  String get clarificationNeeded => 'কিছু তথ্য স্পষ্ট জানা প্রয়োজন';

  @override
  String clarificationWhy(String reason) {
    return 'কেন জানতে চাইছি: $reason';
  }

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get dontKnow => 'জানা নেই';

  @override
  String get supersededNotice => 'আপনার সংশোধনের কারণে এই উত্তর আপডেট হয়েছে।';

  @override
  String get showPreviousGuidance => 'পূর্ববর্তী দিকনির্দেশনা দেখুন';

  @override
  String get hidePreviousGuidance => 'পূর্ববর্তী দিকনির্দেশনা লুকান';

  @override
  String get noConnection =>
      'ইন্টারনেট সংযোগ পাওয়া যাচ্ছে না। আপনার লেখা সংরক্ষিত আছে।';

  @override
  String get serviceUnavailable =>
      'এই মুহূর্তে অনলাইন সহায়তা পাওয়া যাচ্ছে না। একটু পরে আবার চেষ্টা করুন।';

  @override
  String get insufficientSources =>
      'এই বিষয়ে আমাদের কাছে যথেষ্ট নির্ভরযোগ্য আইনগত তথ্য নেই, তাই অনুমান করে কিছু বলছি না।';

  @override
  String get unsupportedScope =>
      'এই বিষয়টি বাংলাদেশের আইনি কাঠামোর আওতাভুক্ত নয়।';

  @override
  String get emergencyNotice =>
      'জরুরি পরিস্থিতি শনাক্ত হয়েছে। অবিলম্বে জাতীয় জরুরি সেবা ৯৯৯ নম্বরে যোগাযোগ করুন।';
}
