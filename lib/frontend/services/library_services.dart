import 'package:dio/dio.dart';
import 'package:inkger/backend/services/api_service.dart';

class LibraryServices {
  static Future<String> loadLibraryPath(String libraryId) async {
    try {
      final response = await ApiService.dio.get(
        '/api/libraries/$libraryId/path',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        if (response.data is String && response.data.contains('<!DOCTYPE html>')) {
          throw Exception('El backend no está respondiendo correctamente');
        }

        final data = response.data as Map<String, dynamic>;
        return data['path'] ?? ''; // Devolver la ruta obtenida
      } else {
        throw Exception('Error ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error cargando la ruta: $e');
      return ''; // En caso de error, devolver una cadena vacía
    }
  }
}