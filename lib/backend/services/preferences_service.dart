import 'dart:convert';
import 'package:inkger/backend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const _comicDirKey = 'comicAppDirectory';
  static const _bookDirKey = 'bookAppDirectory';
  static const _audiobookDirKey = 'audiobookAppDirectory';

  static Future<void> initializeDirectories() async {
    final prefs = await SharedPreferences.getInstance();
    final response = await ApiService.dio.get(
      'http://localhost:3000/api/libraries',
    );

    if (response.statusCode == 200) {
      // Verifica si la respuesta es un Map y decodifica los datos
      final data =
          response
              .data; // Asegúrate de que response.data es Map<String, dynamic>

      // Si data es un Map, puedes acceder a sus claves directamente
      if (data is Map<String, dynamic>) {
        await prefs.setString(_comicDirKey, data['comicPath']);
        await prefs.setString(_bookDirKey, data['bookPath']);
        await prefs.setString(_audiobookDirKey, data['audioPath']);
      } else {
        print('Formato de datos inesperado: $data');
      }
    } else {
      print('Error al obtener rutas: ${response.data}');
    }
  }
}
