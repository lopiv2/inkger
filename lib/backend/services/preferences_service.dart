import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const _comicDirKey = 'comicAppDirectory';
  static const _bookDirKey = 'bookAppDirectory';
  static const _audiobookDirKey = 'audiobookAppDirectory';
  static const _librariesDataKey = 'librariesData';

  static Future<Map<String, String>> initializeDirectories() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await ApiService.dio.get(
        '/api/libraries',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        await Future.wait([
          prefs.setString(_comicDirKey, data['comicPath'] ?? ''),
          prefs.setString(_bookDirKey, data['bookPath'] ?? ''),
          prefs.setString(_audiobookDirKey, data['audioPath'] ?? ''),
        ]);

        return {
          'comicPath': data['comicPath'] ?? '',
          'bookPath': data['bookPath'] ?? '',
          'audioPath': data['audioPath'] ?? '',
        };
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo específico para diferentes tipos de errores
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'No se pudo conectar al servidor. Verifica tu conexión a internet.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Tiempo de espera agotado. El servidor no respondió.');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  static Future<String?> getLibraryPath(String libraryId) async {
    final prefs = await SharedPreferences.getInstance();

    // Primero intentar obtener de las preferencias locales
    final librariesJson = prefs.getString(_librariesDataKey);
    if (librariesJson != null) {
      final libraries = json.decode(librariesJson) as Map<String, dynamic>;
      final libraryData = libraries['libraries']?[libraryId];
      return libraryData?['path']?.toString();
    }

    // Si no está localmente, hacer petición al servidor
    try {
      final response = await ApiService.dio.get(
        '/api/libraries/$libraryId/path',
      );

      if (response.statusCode == 200) {
        return response.data['path']?.toString();
      }
    } catch (e) {
      print('Error al obtener path de biblioteca: $e');
    }

    return null;
  }

  static Future<bool> updateLibraryPath(
    String libraryId,
    String newPath,
  ) async {
    try {
      final response = await ApiService.dio.put(
        '/api/libraries/$libraryId',
        data: {'path': newPath},
      );

      if (response.statusCode == 200) {
        // Actualizar también en preferencias locales
        await initializeDirectories();
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Error al actualizar biblioteca: $e');
      return false;
    }
  }

  // Métodos para obtener rutas específicas
  static Future<String?> getComicDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_comicDirKey);
  }

  static Future<String?> getBookDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bookDirKey);
  }

  static Future<String?> getAudiobookDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_audiobookDirKey);
  }
}
