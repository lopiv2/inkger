import 'package:flutter/material.dart';

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
  final int themeColor;
  final String? backgroundImagePath;
  final double scanInterval;

  Color get themeColorAsColor => Color(themeColor);

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
    required this.themeColor,
    this.backgroundImagePath,
    required this.scanInterval,
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
      defaultGridItemSize = 7,
      themeColor = 4284513675, // valor por defecto
      backgroundImagePath = null,
      scanInterval = 5;

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'languageCode': languageCode,
      'textScaleFactor': textScaleFactor,
      'notificationsEnabled': notificationsEnabled,
      'comicAppDirectory': comicAppDirectory,
      'bookAppDirectory': bookAppDirectory,
      'audiobookAppDirectory': audiobookAppDirectory,
      'fullScreenMode': fullScreenMode,
      'readerMode': readerMode,
      'Comicvine Key': comicvineApiKey,
      'defaultGridItemSize': defaultGridItemSize,
      'themeColor': themeColor, // se guarda como int
      'backgroundImagePath': backgroundImagePath,
      'scanInterval': scanInterval,
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
      themeColor: map['themeColor'] as int,
      backgroundImagePath: map['backgroundImagePath'] as String?,
      scanInterval: map['scanInterval'] as double,
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
    String? googleBooksApiKey,
    double? defaultGridItemSize,
    int? themeColor,
    String? backgroundImagePath,
    double? scanInterval,
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
      fullScreenMode: fullScreenMode ?? this.fullScreenMode,
      readerMode: readerMode ?? this.readerMode,
      comicvineApiKey: comicvineApiKey ?? this.comicvineApiKey,
      defaultGridItemSize: defaultGridItemSize ?? this.defaultGridItemSize,
      themeColor: themeColor ?? this.themeColor,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      scanInterval:  scanInterval ?? this.scanInterval,
    );
  }
}
