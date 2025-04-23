import 'package:flutter/foundation.dart';
import 'package:inkger/backend/services/preferences_service.dart';
import 'package:inkger/frontend/models/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider with ChangeNotifier {
  late AppPreferences _prefs =
      AppPreferences.defaults(); // Inicialización directa;
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
        'fullScreenMode': prefs.getBool('fullScreenMode') ?? false,
        'readerMode': prefs.getBool('readerMode') ?? false,
        'Comicvine Key': prefs.getString('Comicvine Key'),
        'defaultGridItemSize': prefs.getDouble('defaultGridItemSize') ?? 7.0,
        'themeColor': prefs.getString('themeColor') ?? '#2196F3',
        'backgroundImagePath': prefs.getString('backgroundImagePath'),
      });
    } catch (e) {
      _prefs = AppPreferences.defaults();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _prefs = _prefs.copyWith(
      readerMode: prefs.getBool('readerMode') ?? false,
      fullScreenMode: prefs.getBool('fullScreenMode') ?? false,
      // ...otros valores que guardas
    );

    notifyListeners();
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

  if (value is bool) {
    await prefs.setBool(key, value);
  } else if (value is String) {
    await prefs.setString(key, value);
  } else if (value is double) {
    await prefs.setDouble(key, value);
  } else if (value is int) {
    await prefs.setInt(key, value);
  } else if (value == null) {
    await prefs.remove(key);
  }
}

  // Nuevo método para cambiar el modo pantalla completa
  Future<void> toggleFullScreenMode(bool value) async {
    _prefs = _prefs.copyWith(fullScreenMode: value);
    await _savePreference('fullScreenMode', value);
    notifyListeners();
  }

  // Nuevo método para cambiar el modo de lector a escritor
  Future<void> toggleFullReaderMode(bool value) async {
    _prefs = _prefs.copyWith(readerMode: value);
    await _savePreference('readerMode', value);
    notifyListeners();
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

  Future<void> updateLibraryPath(String libraryType, String newPath) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Actualizar el estado según el tipo
      _prefs = _prefs.copyWith(
        comicAppDirectory:
            libraryType == 'comics' ? newPath : _prefs.comicAppDirectory,
        bookAppDirectory:
            libraryType == 'books' ? newPath : _prefs.bookAppDirectory,
        audiobookAppDirectory:
            libraryType == 'audiobooks'
                ? newPath
                : _prefs.audiobookAppDirectory,
      );

      // Persistir en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${libraryType}AppDirectory', newPath);
    } catch (e) {
      debugPrint('Error actualizando ruta: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setAudiobookDirectory(String? path) async {
    _prefs = _prefs.copyWith(audiobookAppDirectory: path);
    await _savePreference('audiobookAppDirectory', path);
    notifyListeners();
  }

  Future<void> setBookDirectory(String? path) async {
    _prefs = _prefs.copyWith(bookAppDirectory: path);
    await _savePreference('bookAppDirectory', path);
    notifyListeners();
  }

  Future<void> setComicDirectory(String? path) async {
    _prefs = _prefs.copyWith(comicAppDirectory: path);
    await _savePreference('comicAppDirectory', path);
    notifyListeners();
  }

  Future<void> setDefaultGridItemSize(double size) async {
    _prefs = _prefs.copyWith(defaultGridItemSize: size);
    await _savePreference('defaultGridItemSize', size);
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
