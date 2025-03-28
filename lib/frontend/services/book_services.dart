import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:inkger/backend/services/api_service.dart';

class BookServices {
  static Future<Response> getAllBooks() async {
    try {
      final response = await ApiService.dio.get(
        '/api/books',
        options: Options(validateStatus: (status) => status! < 500),
      );
      return response;
    } catch (e) {
      throw Exception('Error al obtener los libros: $e');
    }
  }

  static Future<Uint8List?> getBookCover(String coverPath) async {
  try {
    final encodedPath = Uri.encodeComponent(coverPath);
    final response = await ApiService.dio.get(
      '/api/images/$encodedPath',
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null && (response.data as List).isNotEmpty) {
      return Uint8List.fromList(response.data as List<int>);
    }
    return null; // Devuelve null explícitamente para casos de error
  } catch (e) {
    print('Error al obtener portada: $e');
    return null;
  }
}
}
