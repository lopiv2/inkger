class AppPreferences {
  final bool darkMode;
  final String languageCode;
  final double textScaleFactor;
  final bool notificationsEnabled;
  final String? comicAppDirectory;
  final String? bookAppDirectory;
  final String? audiobookAppDirectory;
  final bool fullScreenMode;
  final bool readerMode;
  final String? comicvineApiKey;
  final double defaultGridItemSize; 

  AppPreferences({
    required this.darkMode,
    required this.languageCode,
    required this.textScaleFactor,
    required this.notificationsEnabled,
    this.comicAppDirectory,
    this.bookAppDirectory,
    this.audiobookAppDirectory,
    required this.fullScreenMode,
    required this.readerMode,
    this.comicvineApiKey,
    required this.defaultGridItemSize,
  });

  AppPreferences.defaults()
    : darkMode = false,
      languageCode = 'es',
      textScaleFactor = 1.0,
      notificationsEnabled = true,
      comicAppDirectory = null,
      bookAppDirectory = null,
      audiobookAppDirectory = null,
      fullScreenMode = false,
      readerMode = true,
      comicvineApiKey = null,
      defaultGridItemSize = 7; 

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'languageCode': languageCode,
      'textScaleFactor': textScaleFactor,
      'notificationsEnabled': notificationsEnabled,
      'lastFileDirectory': comicAppDirectory,
      'bookAppDirectory': bookAppDirectory,
      'audiobookAppDirectory': audiobookAppDirectory,
      'fullScreenMode': fullScreenMode,
      'readerMode': readerMode,
      'Comicvine Key': comicvineApiKey,
      'defaultGridItemSize': defaultGridItemSize,
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
      fullScreenMode: map['fullScreenMode'] as bool,
      readerMode: map['readerMode'] as bool,
      comicvineApiKey: map['Comicvine Key'],
      defaultGridItemSize: map['defaultGridItemSize'] as double, 
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
    bool? fullScreenMode,
    bool? readerMode,
    String? comicvineApiKey,
    double? defaultGridItemSize,
  }) {
    return AppPreferences(
      darkMode: darkMode ?? this.darkMode,
      languageCode: languageCode ?? this.languageCode,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      comicAppDirectory: comicAppDirectory ?? this.comicAppDirectory,
      bookAppDirectory: bookAppDirectory ?? this.bookAppDirectory,
      audiobookAppDirectory: audiobookAppDirectory ?? this.audiobookAppDirectory,
      fullScreenMode: fullScreenMode ?? this.fullScreenMode,
      readerMode: readerMode ?? this.readerMode,
      comicvineApiKey: comicvineApiKey ?? this.comicvineApiKey,
      defaultGridItemSize: defaultGridItemSize ?? this.defaultGridItemSize,
    );
  }
}
