// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MyLaws';

  @override
  String get appSubtitle =>
      'Bangladesh Legal Information & Document Preparation';

  @override
  String get homeGreeting => 'Tell us what happened';

  @override
  String get homeSupporting =>
      'Describe the situation in your own words. We\'ll help you understand the next steps in simple terms.';

  @override
  String get composerHint => 'Write your legal question or situation here...';

  @override
  String get send => 'Send';

  @override
  String get stop => 'Stop';

  @override
  String get retry => 'Retry';

  @override
  String get edit => 'Edit';

  @override
  String characterLimit(int count, int limit) {
    return '$count / $limit';
  }

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Create Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueAsGuest => 'Continue without an account';

  @override
  String get guestNotice =>
      'Guest mode: Online assistant is disabled. Installed legal sources, local drafts, and offline guidance work completely on your phone.';

  @override
  String get email => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get account => 'Account';

  @override
  String get modeOnline => 'Online Assistant';

  @override
  String get modeOnlineGuided => 'Online Guided';

  @override
  String get modeOfflineInstalled => 'Offline: Law Pack Installed';

  @override
  String get modeOfflineUnavailable => 'Offline: Install Law Pack';

  @override
  String get modeSample => 'Sample Mode (Dev)';

  @override
  String quotaRemaining(int remaining, int limit) {
    return '$remaining of $limit questions left today';
  }

  @override
  String get quotaExhausted =>
      'Today\'s online question limit is reached. Installed legal sources and drafts still work.';

  @override
  String get quotaUnknown => 'Quota: Unknown (Offline/Guest)';

  @override
  String get sources => 'Legal Sources';

  @override
  String sourcesCount(int count) {
    return '$count sources cited';
  }

  @override
  String get sourceVerified => 'In Force';

  @override
  String get sourceMachineChecked =>
      'Machine-checked, not reviewed by a lawyer';

  @override
  String get viewOriginalLaw => 'View original statutory section';

  @override
  String get openOfficialLink => 'Open official BDLaws portal';

  @override
  String get checklist => 'Action Checklist';

  @override
  String get requiredDocuments => 'Required Documents';

  @override
  String get helpfulEvidence => 'Helpful Evidence';

  @override
  String get undo => 'Undo';

  @override
  String get stepRecheck => 'Needs recheck after update';

  @override
  String get drafts => 'Drafts';

  @override
  String get prepareDraft => 'Prepare Draft';

  @override
  String get draftNotice =>
      'This is a preparation draft. It has not been filed or submitted to any authority.';

  @override
  String get incompleteDraft => 'Incomplete Draft · Details Needed';

  @override
  String get readyDraft => 'Draft Ready for Review & Export';

  @override
  String get reviewCheckbox =>
      'I have reviewed all facts, dates, and recipient details.';

  @override
  String get copyText => 'Copy Text';

  @override
  String get savePdf => 'Save PDF';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get print => 'Print';

  @override
  String get downloads => 'Downloads & Offline';

  @override
  String get legalPack => 'Statutory Law Pack';

  @override
  String get legalPackDesc =>
      'Official statutory provisions for offline search and citation verification.';

  @override
  String get localModel => 'Offline AI Model (Optional)';

  @override
  String get localModelDesc =>
      'Runs on-device AI for legal guidance. Requires compatible 4GB+ RAM Android device.';

  @override
  String installedVersion(String version) {
    return 'Installed: $version';
  }

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get removePack => 'Remove Pack';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get language => 'Language';

  @override
  String get largerText => 'Larger Text';

  @override
  String get wifiOnly => 'Download over Wi-Fi only';

  @override
  String get autoUpdate => 'Auto-update public legal pack';

  @override
  String get preferOffline => 'Prefer offline processing';

  @override
  String get privacy => 'Privacy & Data';

  @override
  String get cloudProcessing => 'Allow cloud AI processing';

  @override
  String get cloudHistory => 'Sync conversation history to cloud';

  @override
  String get hideContentSwitcher => 'Hide content in app switcher';

  @override
  String get deleteConversations => 'Delete local conversations';

  @override
  String get deleteDrafts => 'Delete local drafts';

  @override
  String get deleteAllLocal => 'Delete all local data';

  @override
  String get deleteCloudHistory => 'Delete cloud history';

  @override
  String get deleteAccount => 'Delete account permanently';

  @override
  String get about => 'About & Disclaimer';

  @override
  String get disclaimerText =>
      'MyLaws provides legal information and document preparation assistance. It is NOT a lawyer, NOT a law firm, and NOT a government authority. It never files or submits anything on your behalf.';

  @override
  String get licenses => 'Open Source Licenses';

  @override
  String get clarificationNeeded => 'Clarification Needed';

  @override
  String clarificationWhy(String reason) {
    return 'Why we ask: $reason';
  }

  @override
  String get skip => 'Skip';

  @override
  String get dontKnow => 'I don\'t know';

  @override
  String get supersededNotice => 'Updated after your correction.';

  @override
  String get showPreviousGuidance => 'Show previous guidance';

  @override
  String get hidePreviousGuidance => 'Hide previous guidance';

  @override
  String get noConnection => 'No internet connection. Your message is saved.';

  @override
  String get serviceUnavailable =>
      'Online help is currently unavailable. Please try again shortly.';

  @override
  String get insufficientSources =>
      'We could not find enough reliable legal sources for this situation, so we will not guess.';

  @override
  String get unsupportedScope =>
      'This inquiry falls outside the scope of Bangladesh statutory law.';

  @override
  String get emergencyNotice =>
      'Emergency detected. Please contact national emergency services immediately.';
}
