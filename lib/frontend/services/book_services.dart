import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookServices {
  static Future<void> convertToFormat(int ebookId, String format) async {
    try {
      final response = await ApiService.dio.post(
        '/api/books/$ebookId/convert',
        data: {'format': format},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al convertir el ebook a $format: ${response.data}',
        );
      }
    } catch (e) {
      print('Error al convertir el ebook a $format: $e');
      rethrow;
    }
  }

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

  static Future<Response> getAllBooks(int id) async {
    try {
      final response = await ApiService.dio.get(
        '/api/books',
        queryParameters: {'userId': id}, // <- Parámetro en la URL
        options: Options(validateStatus: (status) => status! < 500),
      );
      return response;
    } catch (e) {
      throw Exception('Error al obtener los libros: $e');
    }
  }

  static Future<Uint8List> getBookFile(String bookId) async {
    try {
      final response = await ApiService.dio.get(
        '/api/bookfile/$bookId',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw Exception('Error al cargar el libro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener el libro: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getBookMetadata(
    String query,
    Book book,
    openLibrary,
    ibdb,
    googleBooks,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');
      final response = await ApiService.dio.post(
        '/api/books/search-metadata',
        data: {
          'query': query,
          'book': {
            'title': book.title,
            'author': book.author,
            'publisher': book.publisher,
            'publishDate': book.publicationDate.toString(),
            // Añade otros campos si los necesitas
          },
          'sources': {
            'openLibrary': openLibrary,
            'ibdb': ibdb,
            'googleBooks': googleBooks,
          },
        },
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error al buscar libros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener metadatos: $e');
    }
  }

  static Future<void> saveReadingProgress(
    int bookId,
    int progress,
    BuildContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    try {
      final response = await ApiService.dio.post(
        '/api/bookfile/save-progress',
        data: jsonEncode({
          'user_id': id,
          'book_id': bookId,
          'progress': progress.clamp(1, 100), // Asegura valor entre 1-100
          'timestamp': DateTime.now().toIso8601String(),
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al guardar progreso');
      }
      if (context.mounted) {
        // ✅ Verificar si el widget sigue montado antes de usar el contexto
        CustomSnackBar.show(
          context,
          '${AppLocalizations.of(context)!.savedProgress}: $progress%',
          Colors.green,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // ✅ Verificar antes de mostrar el error
        CustomSnackBar.show(
          context,
          'Error guardando progreso: ${e.toString()}',
          Colors.red,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  static Future<void> saveReadState(
    int bookId,
    bool read,
    BuildContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    try {
      final response = await ApiService.dio.post(
        '/api/bookfile/save-read-state',
        data: jsonEncode({
          'user_id': id,
          'book_id': bookId,
          'read': read, // Asegura valor entre 1-100
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al guardar progreso');
      }
      if (context.mounted) {
        // ✅ Verificar si el widget sigue montado antes de usar el contexto
        /*CustomSnackBar.show(
          context,
          '${AppLocalizations.of(context)!.savedProgress}: $read%',
          Colors.green,
          duration: const Duration(seconds: 4),
        );*/
      }
    } catch (e) {
      if (context.mounted) {
        // ✅ Verificar antes de mostrar el error
        CustomSnackBar.show(
          context,
          'Error guardando estado lectura: ${e.toString()}',
          Colors.red,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  static Future<void> showDeleteConfirmationDialog(
    BuildContext context,
    Book book,
  ) async {
    return showDialog<void>(
      context: Navigator.of(context, rootNavigator: true).context,
      barrierDismissible: false, // El usuario debe tocar un botón para cerrar
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '¿Estás seguro de que quieres eliminar el libro "${book.title}"?',
                ),
                const SizedBox(height: 8),
                const Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el diálogo primero
                try {
                  await BookServices.deleteBook(context, book);
                  // Opcional: Mostrar mensaje de éxito
                  CustomSnackBar.show(
                    context,
                    '"${book.title}" eliminado correctamente',
                    Colors.green,
                    duration: Duration(seconds: 4),
                  );
                } catch (e) {
                  CustomSnackBar.show(
                    context,
                    'Error al eliminar: ${e.toString()}',
                    Colors.red,
                    duration: Duration(seconds: 4),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> updateBook(Book book) async {
    try {
      final response = await ApiService.dio.put(
        '/api/books/${book.id}',
        data: jsonEncode(book.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Book> fetchBookById(int bookId, int userId) async {
    try {
      final response = await ApiService.dio.get(
        '/api/books/$bookId',
        queryParameters: {'userId': userId}, // Agrega el userId como parámetro
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        return Book.fromJson(
          response.data,
        ); // Convierte la respuesta en un objeto Book
      } else {
        throw Exception('Error al obtener el libro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener el libro: $e');
    }
  }
}
