import 'package:inkger/backend/services/api_service.dart';

class BookFoldersService {
  static Future<void> saveBooksTreeStructure(
    List<Map<String, dynamic>> tree,
  ) async {
    try {
      final response = await ApiService.dio.post(
        '/api/writer/books/tree',
        data: {'tree': tree},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al guardar la estructura de carpetas');
      }
    } catch (e) {
      rethrow;
    }
  }
}
