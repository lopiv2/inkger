import 'package:flutter/foundation.dart';
import 'package:inkger/backend/services/preferences_service.dart';
import 'package:inkger/frontend/models/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider with ChangeNotifier {
  late AppPreferences _prefs;
  bool _isLoading = true;

  AppPreferences get preferences => _prefs;
  bool get isLoading => _isLoading;

  PreferencesProvider() {
    _loadPreferences();
  }

  // Método para cargar las preferencias
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Llamar a PreferenceService para obtener las rutas del backend si es necesario
      //await PreferenceService.initializeDirectories(); // Esto actualiza las rutas en SharedPreferences

      // Obtener las preferencias locales
      _prefs = AppPreferences.fromMap({
        'darkMode': prefs.getBool('darkMode') ?? false,
        'languageCode': prefs.getString('languageCode') ?? 'es',
        'textScaleFactor': prefs.getDouble('textScaleFactor') ?? 1.0,
        'notificationsEnabled': prefs.getBool('notificationsEnabled') ?? true,
        'comicAppDirectory': prefs.getString('comicAppDirectory'),
        'bookAppDirectory': prefs.getString('bookAppDirectory'),
        'audiobookAppDirectory': prefs.getString('audiobookAppDirectory'),
      });
    } catch (e) {
      _prefs = AppPreferences.defaults();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para actualizar las rutas desde el backend
  Future<void> refreshPathsFromDatabase() async {
    try {
      await PreferenceService.initializeDirectories(); // Esto asegura que las rutas estén actualizadas

      final prefs = await SharedPreferences.getInstance();
      _prefs = _prefs.copyWith(
        comicAppDirectory: prefs.getString('comicAppDirectory'),
        bookAppDirectory: prefs.getString('bookAppDirectory'),
        audiobookAppDirectory: prefs.getString('audiobookAppDirectory'),
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing paths: $e');
    }
  }

  // Método para guardar preferencias
  Future<void> _savePreference<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    
    switch (T) {
      case bool:
        await prefs.setBool(key, value as bool);
        break;
      case String:
        await prefs.setString(key, value as String);
        break;
      case double:
        await prefs.setDouble(key, value as double);
        break;
      case int:
        await prefs.setInt(key, value as int);
        break;
      default:
        if (value == null) {
          await prefs.remove(key);
        }
    }
  }

  // Método para actualizar las preferencias
  Future<void> updatePreferences(AppPreferences newPrefs) async {
    _prefs = newPrefs;
    notifyListeners();

    final map = newPrefs.toMap();
    for (final entry in map.entries) {
      await _savePreference(entry.key, entry.value);
    }
  }

  // Métodos específicos para cada preferencia
  Future<void> setDarkMode(bool value) async {
    _prefs = _prefs.copyWith(darkMode: value);
    await _savePreference('darkMode', value);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _prefs = _prefs.copyWith(languageCode: languageCode);
    await _savePreference('languageCode', languageCode);
    notifyListeners();
  }

  Future<void> setComicDirectory(String? path) async {
    _prefs = _prefs.copyWith(comicAppDirectory: path);
    await _savePreference('comicAppDirectory', path);
    notifyListeners();
  }

  Future<void> setBookDirectory(String? path) async {
    _prefs = _prefs.copyWith(bookAppDirectory: path);
    await _savePreference('bookAppDirectory', path);
    notifyListeners();
  }

  Future<void> setAudiobookDirectory(String? path) async {
    _prefs = _prefs.copyWith(audiobookAppDirectory: path);
    await _savePreference('audiobookAppDirectory', path);
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double factor) async {
    _prefs = _prefs.copyWith(textScaleFactor: factor);
    await _savePreference('textScaleFactor', factor);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _prefs = _prefs.copyWith(notificationsEnabled: enabled);
    await _savePreference('notificationsEnabled', enabled);
    notifyListeners();
  }

  // Método para resetear a valores por defecto
  Future<void> resetToDefaults() async {
    _prefs = AppPreferences.defaults();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
