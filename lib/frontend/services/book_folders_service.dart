import 'package:inkger/backend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookFoldersService {
  static Future<void> saveBooksTreeStructure(
    List<Map<String, dynamic>> tree,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    try {
      final response = await ApiService.dio.post(
        '/api/writer/books/tree',
        data: {'userId': userId, 'tree': tree},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al guardar la estructura de carpetas');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchBooksTreeStructure() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    if (userId == null) {
      throw Exception('El userId no está disponible en las preferencias');
    }
    try {
      final response = await ApiService.dio.get(
        '/api/writer/books/tree/$userId', // Usar el parámetro de ruta para userId
      );
      if (response.statusCode == 200 && response.data != null) {
        final tree = response.data['tree'];
        if (tree is List) {
          return List<Map<String, dynamic>>.from(
            tree.map((item) {
              return {
                'key': item['key'], // Asegúrate de incluir el key
                'name': item['name'],
                'icon': item['icon'] ?? 'folder',
                'children': item['children'] != null && item['children'] is List
                    ? List<Map<String, dynamic>>.from(item['children'])
                    : [],
              };
            }),
          );
        }
        return [];
      } else {
        throw Exception('Error al obtener la estructura de carpetas');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteBooksFolderNode(dynamic nodeId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    try {
      final response = await ApiService.dio.delete(
        '/api/writer/books/folder',
        data: {'userId': userId, 'nodeId': nodeId},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar el nodo de carpeta');
      }
    } catch (e) {
      rethrow;
    }
  }
}
