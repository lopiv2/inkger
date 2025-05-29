import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComicServices {
  static Future<void> convertToCBR(int comicId) async {}

  static Future<void> convertToCBZ(BuildContext context, int comicId) async {
    try {
      final response = await ApiService.dio.get('/api/convert-to-cbz/$comicId');

      if (!context.mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars(); // Limpia snackbars anteriores
      final message = response.data['message'];
      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context,
          message ?? '',
          Colors.green,
          duration: Duration(seconds: 4),
        );
      } else {
        CustomSnackBar.show(
          context,
          'Error al convertir (${response.statusCode})',
          Colors.red,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      debugPrint('Error en convertToCBZ: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  static Future<void> deletecomic(BuildContext context, Comic comic) async {
    try {
      final comicsProvider = Provider.of<ComicsProvider>(
        context,
        listen: false,
      );

      // 1. Llamar a la API para eliminar el comic
      final response = await ApiService.dio.delete('/api/comics/${comic.id}');

      if (response.statusCode == 200) {
        // 2. Eliminar del Provider
        comicsProvider.removeComic(comic.id);

        debugPrint("Comic eliminado correctamente: ${comic.title}");
      } else {
        debugPrint("Error al eliminar el comic: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error eliminando el comic: $e");
    }
  }

  static Future<void> downloadComic(dynamic comicId, String title, String extension) async {
    try {
      final response = await ApiService.dio.get(
        '/api/comics/download/$comicId',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      String? fileName;
      fileName ??= '$title.$extension'; // Valor por defecto si no hay cabecera
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      html.document.body!.append(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error al descargar el cómic: $e');
    }
  }

  static Future<Response> getAllcomics(int id) async {
    try {
      final response = await ApiService.dio.get(
        '/api/comics',
        queryParameters: {'userId': id}, // <- Parámetro en la URL
        options: Options(validateStatus: (status) => status! < 500),
      );
      return response;
    } catch (e) {
      throw Exception('Error al obtener los comics: $e');
    }
  }

  static Future<Uint8List> getcomicFile(String comicId) async {
    try {
      final response = await ApiService.dio.get(
        '/api/comicfile/$comicId',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw Exception('Error al cargar el comic: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener el comic: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getComicMetadata(
    int userId,
    String comic,
  ) async {
    try {
      final response = await ApiService.dio.get(
        '/api/comics/search-metadata/$userId/$comic', // Aquí pasas tanto el userId como el comic
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200) {
        // Si la respuesta es un array, puedes devolverla como lista
        List<dynamic> data = response.data;

        // Opcional: Si necesitas procesar los datos para extraer ciertos campos
        List<Map<String, dynamic>> comics = data.map((item) {
          return {
            'id': item['id'],
            'name': item['name'],
            'publisher': item['publisher'],
            'year': item['start_year'],
            'count_of_issues': item['count_of_issues'] ?? 0,
            'image': item['image'] ?? '', // Aquí manejas la imagen de portada
          };
        }).toList();

        return comics;
      } else {
        throw Exception('Error al cargar el comic: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener el comic: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getIssuesForVolume(
    int userId,
    String volumeId,
  ) async {
    final response = await ApiService.dio.get(
      '/api/comics/search-volume-issues/$userId/$volumeId',
      options: Options(responseType: ResponseType.json),
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // Ya es una lista directamente
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Se esperaba una lista, se recibió: ${data.runtimeType}',
        );
      }
    } else {
      throw Exception('Error al obtener los issues del volumen');
    }
  }

  static Future<Map<String, dynamic>> getIssueInfo(
    int userId,
    int issueId,
  ) async {
    final response = await ApiService.dio.get(
      '/api/comics/search-issue-data/$userId/$issueId',
      options: Options(responseType: ResponseType.json),
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // Ya es una lista directamente
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception(
          'Se esperaba una lista, se recibió: ${data.runtimeType}',
        );
      }
    } else {
      throw Exception('Error al obtener los issues del volumen');
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
        '/api/comicfile/save-read-state',
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
  
  static Future<void> saveReadingProgress(
    int comicId,
    int progress,
    BuildContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    try {
      final response = await ApiService.dio.post(
        '/api/comicfile/save-progress',
        data: jsonEncode({
          'user_id': id,
          'comic_id': comicId,
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
      // Opcional: Guardar localmente para sincronizar después
      //await _saveProgressOffline(comicId, progress);
    }
  }

  static Future<void> sendDataComicToSave(
    Map<String, dynamic> selectedIssue,
    BuildContext context,
    Comic comic,
    String volumeTitle,
    String publisher,
  ) async {
    try {
      final response = await ApiService.dio.post(
        '/api/comics/save-metadata', // Ajusta según tu endpoint
        data: {
          ...selectedIssue,
          'comic_id': comic.id,
          'volumeTitle': volumeTitle,
          'publisher': publisher,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context,
          'Metadatos de Comic actualizados',
          Colors.green,
          duration: const Duration(seconds: 4),
        );
      } else {
        print('Error al guardar el cómic: ${response.data['error']}');
      }
    } catch (e) {
      print('Excepción al guardar el cómic: $e');
    }
  }

  static Future<void> showDeleteConfirmationDialog(
    BuildContext context,
    Comic comic,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe tocar un botón para cerrar
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '¿Estás seguro de que quieres eliminar el libro "${comic.title}"?',
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
                  await ComicServices.deletecomic(context, comic);
                  // Opcional: Mostrar mensaje de éxito
                  CustomSnackBar.show(
                    context,
                    '"${comic.title}" eliminado correctamente',
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
  
  static Future<void> updateComic(Comic comic) async {
    try {
      final response = await ApiService.dio.put(
        '/api/comics/${comic.id}',
        data: jsonEncode(comic.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Comic> fetchComicById(int comicId, int userId) async {
    try {
      final response = await ApiService.dio.get(
        '/api/comics/$comicId',
        queryParameters: {'userId': userId}, // Agrega el userId como parámetro
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        return Comic.fromJson(
          response.data,
        ); // Convierte la respuesta en un objeto Comic
      } else {
        throw Exception('Error al obtener el cómic: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener el cómic: $e');
    }
  }
}
