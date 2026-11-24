enum AppThemeMode { system, light, dark }

enum AnswerLanguagePreference { sameAsApp, bn, en }

class UserSettings {
  final AppThemeMode themeMode;
  final String appLanguage; // 'bn' or 'en'
  final AnswerLanguagePreference answerLanguage;
  final bool largerText;
  final bool wifiOnly;
  final bool autoUpdateLaws;
  final bool preferOffline;
  final bool cloudProcessingAllowed;
  final bool cloudHistorySync;
  final bool hideContentInAppSwitcher;

  const UserSettings({
    this.themeMode = AppThemeMode.light,
    this.appLanguage = 'en',
    this.answerLanguage = AnswerLanguagePreference.sameAsApp,
    this.largerText = false,
    this.wifiOnly = true,
    this.autoUpdateLaws = true,
    this.preferOffline = false,
    this.cloudProcessingAllowed = true,
    this.cloudHistorySync = false,
    this.hideContentInAppSwitcher = false,
  });

  UserSettings copyWith({
    AppThemeMode? themeMode,
    String? appLanguage,
    AnswerLanguagePreference? answerLanguage,
    bool? largerText,
    bool? wifiOnly,
    bool? autoUpdateLaws,
    bool? preferOffline,
    bool? cloudProcessingAllowed,
    bool? cloudHistorySync,
    bool? hideContentInAppSwitcher,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      appLanguage: appLanguage ?? this.appLanguage,
      answerLanguage: answerLanguage ?? this.answerLanguage,
      largerText: largerText ?? this.largerText,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      autoUpdateLaws: autoUpdateLaws ?? this.autoUpdateLaws,
      preferOffline: preferOffline ?? this.preferOffline,
      cloudProcessingAllowed:
          cloudProcessingAllowed ?? this.cloudProcessingAllowed,
      cloudHistorySync: cloudHistorySync ?? this.cloudHistorySync,
      hideContentInAppSwitcher:
          hideContentInAppSwitcher ?? this.hideContentInAppSwitcher,
    );
  }
}

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Stream<UserSettings> watchSettings();
  Future<void> updateSettings(UserSettings settings);
}
