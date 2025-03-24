// lib/providers/app_preferences.dart
class AppPreferences {
  final bool darkMode;
  final String languageCode;
  final double textScaleFactor;
  final bool notificationsEnabled;
  final String? comicAppDirectory;
  final String? bookAppDirectory;
  final String? audiobookAppDirectory;

  AppPreferences({
    required this.darkMode,
    required this.languageCode,
    required this.textScaleFactor,
    required this.notificationsEnabled,
    this.comicAppDirectory,
    this.bookAppDirectory,
    this.audiobookAppDirectory,
  });

  AppPreferences.defaults()
    : darkMode = false,
      languageCode = 'es',
      textScaleFactor = 1.0,
      notificationsEnabled = true,
      comicAppDirectory = null,
      bookAppDirectory = null,
      audiobookAppDirectory = null;

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'languageCode': languageCode,
      'textScaleFactor': textScaleFactor,
      'notificationsEnabled': notificationsEnabled,
      'lastFileDirectory': comicAppDirectory,
      'bookAppDirectory': bookAppDirectory,
      'audiobookAppDirectory': audiobookAppDirectory,
    };
  }

  factory AppPreferences.fromMap(Map<String, dynamic> map) {
    return AppPreferences(
      darkMode: map['darkMode'] as bool,
      languageCode: map['languageCode'] as String,
      textScaleFactor: map['textScaleFactor'] as double,
      notificationsEnabled: map['notificationsEnabled'] as bool,
      comicAppDirectory: map['comicAppDirectory'] as String?,
      bookAppDirectory: map['bookAppDirectory'] as String?,
      audiobookAppDirectory: map['audiobookAppDirectory'] as String?,
    );
  }
  AppPreferences copyWith({
    bool? darkMode,
    String? languageCode,
    double? textScaleFactor,
    bool? notificationsEnabled,
    String? comicAppDirectory,
    String? bookAppDirectory,
    String? audiobookAppDirectory,
  }) {
    return AppPreferences(
      darkMode: darkMode ?? this.darkMode,
      languageCode: languageCode ?? this.languageCode,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      comicAppDirectory: comicAppDirectory ?? this.comicAppDirectory,
      bookAppDirectory: bookAppDirectory ?? this.bookAppDirectory,
      audiobookAppDirectory:
          audiobookAppDirectory ?? this.audiobookAppDirectory,
    );
  }
}
