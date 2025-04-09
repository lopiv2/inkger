import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComicServices {
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

  static Future<Uint8List?> getComicCover(String coverPath) async {
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

  //ARREGLAR ESTO
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
          'Progreso guardado: $progress%',
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
  static Future<void> updateComic(Comic comic) async {
    try {
      final response = await ApiService.dio.put(
        '/api/comic/${comic.id}',
        data: jsonEncode(comic.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
