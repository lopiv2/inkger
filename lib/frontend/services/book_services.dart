import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:provider/provider.dart';

class BookServices {
  static Future<void> deleteBook(BuildContext context, Book book) async {
    try {
      final booksProvider = Provider.of<BooksProvider>(context, listen: false);

      // 1. Llamar a la API para eliminar el libro
      final response = await ApiService.dio.delete('/api/books/${book.id}');

      if (response.statusCode == 200) {
        // 2. Eliminar del Provider
        booksProvider.removeBook(book.id);

        debugPrint("Libro eliminado correctamente: ${book.title}");
      } else {
        debugPrint("Error al eliminar el libro: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error eliminando el libro: $e");
    }
  }

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

      if (response.statusCode == 200 &&
          response.data != null &&
          (response.data as List).isNotEmpty) {
        return Uint8List.fromList(response.data as List<int>);
      }
      return null; // Devuelve null explícitamente para casos de error
    } catch (e) {
      print('Error al obtener portada: $e');
      return null;
    }
  }

  static Future<Response> getBookFile(String bookId) async {
  try {
    final response = await ApiService.dio.get(
      '/api/bookfile/$bookId', // Ruta que devuelve el archivo
      options: Options(
        responseType: ResponseType.json, // Cambiar a json si el backend devuelve un objeto JSON
      ),
    );
    return response;
  } catch (e) {
    throw Exception('Error al obtener el archivo: $e');
  }
}

}
