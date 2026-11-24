import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MyLaws'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bangladesh Legal Information & Document Preparation'**
  String get appSubtitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened'**
  String get homeGreeting;

  /// No description provided for @homeSupporting.
  ///
  /// In en, this message translates to:
  /// **'Describe the situation in your own words. We\'ll help you understand the next steps in simple terms.'**
  String get homeSupporting;

  /// No description provided for @composerHint.
  ///
  /// In en, this message translates to:
  /// **'Write your legal question or situation here...'**
  String get composerHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @characterLimit.
  ///
  /// In en, this message translates to:
  /// **'{count} / {limit}'**
  String characterLimit(int count, int limit);

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get continueAsGuest;

  /// No description provided for @guestNotice.
  ///
  /// In en, this message translates to:
  /// **'Guest mode: Online assistant is disabled. Installed legal sources, local drafts, and offline guidance work completely on your phone.'**
  String get guestNotice;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @modeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online Assistant'**
  String get modeOnline;

  /// No description provided for @modeOnlineGuided.
  ///
  /// In en, this message translates to:
  /// **'Online Guided'**
  String get modeOnlineGuided;

  /// No description provided for @modeOfflineInstalled.
  ///
  /// In en, this message translates to:
  /// **'Offline: Law Pack Installed'**
  String get modeOfflineInstalled;

  /// No description provided for @modeOfflineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Offline: Install Law Pack'**
  String get modeOfflineUnavailable;

  /// No description provided for @modeSample.
  ///
  /// In en, this message translates to:
  /// **'Sample Mode (Dev)'**
  String get modeSample;

  /// No description provided for @quotaRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {limit} questions left today'**
  String quotaRemaining(int remaining, int limit);

  /// No description provided for @quotaExhausted.
  ///
  /// In en, this message translates to:
  /// **'Today\'s online question limit is reached. Installed legal sources and drafts still work.'**
  String get quotaExhausted;

  /// No description provided for @quotaUnknown.
  ///
  /// In en, this message translates to:
  /// **'Quota: Unknown (Offline/Guest)'**
  String get quotaUnknown;

  /// No description provided for @sources.
  ///
  /// In en, this message translates to:
  /// **'Legal Sources'**
  String get sources;

  /// No description provided for @sourcesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sources cited'**
  String sourcesCount(int count);

  /// No description provided for @sourceVerified.
  ///
  /// In en, this message translates to:
  /// **'In Force'**
  String get sourceVerified;

  /// No description provided for @sourceMachineChecked.
  ///
  /// In en, this message translates to:
  /// **'Machine-checked, not reviewed by a lawyer'**
  String get sourceMachineChecked;

  /// No description provided for @viewOriginalLaw.
  ///
  /// In en, this message translates to:
  /// **'View original statutory section'**
  String get viewOriginalLaw;

  /// No description provided for @openOfficialLink.
  ///
  /// In en, this message translates to:
  /// **'Open official BDLaws portal'**
  String get openOfficialLink;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Action Checklist'**
  String get checklist;

  /// No description provided for @requiredDocuments.
  ///
  /// In en, this message translates to:
  /// **'Required Documents'**
  String get requiredDocuments;

  /// No description provided for @helpfulEvidence.
  ///
  /// In en, this message translates to:
  /// **'Helpful Evidence'**
  String get helpfulEvidence;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @stepRecheck.
  ///
  /// In en, this message translates to:
  /// **'Needs recheck after update'**
  String get stepRecheck;

  /// No description provided for @drafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get drafts;

  /// No description provided for @prepareDraft.
  ///
  /// In en, this message translates to:
  /// **'Prepare Draft'**
  String get prepareDraft;

  /// No description provided for @draftNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a preparation draft. It has not been filed or submitted to any authority.'**
  String get draftNotice;

  /// No description provided for @incompleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Draft · Details Needed'**
  String get incompleteDraft;

  /// No description provided for @readyDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft Ready for Review & Export'**
  String get readyDraft;

  /// No description provided for @reviewCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I have reviewed all facts, dates, and recipient details.'**
  String get reviewCheckbox;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get copyText;

  /// No description provided for @savePdf.
  ///
  /// In en, this message translates to:
  /// **'Save PDF'**
  String get savePdf;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads & Offline'**
  String get downloads;

  /// No description provided for @legalPack.
  ///
  /// In en, this message translates to:
  /// **'Statutory Law Pack'**
  String get legalPack;

  /// No description provided for @legalPackDesc.
  ///
  /// In en, this message translates to:
  /// **'Official statutory provisions for offline search and citation verification.'**
  String get legalPackDesc;

  /// No description provided for @localModel.
  ///
  /// In en, this message translates to:
  /// **'Offline AI Model (Optional)'**
  String get localModel;

  /// No description provided for @localModelDesc.
  ///
  /// In en, this message translates to:
  /// **'Runs on-device AI for legal guidance. Requires compatible 4GB+ RAM Android device.'**
  String get localModelDesc;

  /// No description provided for @installedVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed: {version}'**
  String installedVersion(String version);

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @removePack.
  ///
  /// In en, this message translates to:
  /// **'Remove Pack'**
  String get removePack;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @largerText.
  ///
  /// In en, this message translates to:
  /// **'Larger Text'**
  String get largerText;

  /// No description provided for @wifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Download over Wi-Fi only'**
  String get wifiOnly;

  /// No description provided for @autoUpdate.
  ///
  /// In en, this message translates to:
  /// **'Auto-update public legal pack'**
  String get autoUpdate;

  /// No description provided for @preferOffline.
  ///
  /// In en, this message translates to:
  /// **'Prefer offline processing'**
  String get preferOffline;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get privacy;

  /// No description provided for @cloudProcessing.
  ///
  /// In en, this message translates to:
  /// **'Allow cloud AI processing'**
  String get cloudProcessing;

  /// No description provided for @cloudHistory.
  ///
  /// In en, this message translates to:
  /// **'Sync conversation history to cloud'**
  String get cloudHistory;

  /// No description provided for @hideContentSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Hide content in app switcher'**
  String get hideContentSwitcher;

  /// No description provided for @deleteConversations.
  ///
  /// In en, this message translates to:
  /// **'Delete local conversations'**
  String get deleteConversations;

  /// No description provided for @deleteDrafts.
  ///
  /// In en, this message translates to:
  /// **'Delete local drafts'**
  String get deleteDrafts;

  /// No description provided for @deleteAllLocal.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data'**
  String get deleteAllLocal;

  /// No description provided for @deleteCloudHistory.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud history'**
  String get deleteCloudHistory;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account permanently'**
  String get deleteAccount;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About & Disclaimer'**
  String get about;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'MyLaws provides legal information and document preparation assistance. It is NOT a lawyer, NOT a law firm, and NOT a government authority. It never files or submits anything on your behalf.'**
  String get disclaimerText;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get licenses;

  /// No description provided for @clarificationNeeded.
  ///
  /// In en, this message translates to:
  /// **'Clarification Needed'**
  String get clarificationNeeded;

  /// No description provided for @clarificationWhy.
  ///
  /// In en, this message translates to:
  /// **'Why we ask: {reason}'**
  String clarificationWhy(String reason);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @dontKnow.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know'**
  String get dontKnow;

  /// No description provided for @supersededNotice.
  ///
  /// In en, this message translates to:
  /// **'Updated after your correction.'**
  String get supersededNotice;

  /// No description provided for @showPreviousGuidance.
  ///
  /// In en, this message translates to:
  /// **'Show previous guidance'**
  String get showPreviousGuidance;

  /// No description provided for @hidePreviousGuidance.
  ///
  /// In en, this message translates to:
  /// **'Hide previous guidance'**
  String get hidePreviousGuidance;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Your message is saved.'**
  String get noConnection;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Online help is currently unavailable. Please try again shortly.'**
  String get serviceUnavailable;

  /// No description provided for @insufficientSources.
  ///
  /// In en, this message translates to:
  /// **'We could not find enough reliable legal sources for this situation, so we will not guess.'**
  String get insufficientSources;

  /// No description provided for @unsupportedScope.
  ///
  /// In en, this message translates to:
  /// **'This inquiry falls outside the scope of Bangladesh statutory law.'**
  String get unsupportedScope;

  /// No description provided for @emergencyNotice.
  ///
  /// In en, this message translates to:
  /// **'Emergency detected. Please contact national emergency services immediately.'**
  String get emergencyNotice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
