import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriterServices {
  static Future<List<String>> fetchGeneratedNames({
    required String type,
    required String generator,
    required int number,
  }) async {
    try {
      final response = await ApiService.dio.get(
        '/api/writer/generate-names',
        queryParameters: {
          'type': type,
          'generator': generator,
          'number': number.toString(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map && data['names'] is List) {
          final List<dynamic> names = data['names'];
          return names.map((name) => name.toString()).toList();
        } else {
          throw Exception('La estructura de los nombres no es válida');
        }
      } else {
        throw Exception('Error al obtener nombres: ${response.data["error"]}');
      }
    } catch (e) {
      throw Exception('Fallo al conectar con el servidor: $e');
    }
  }

  static Future<String> getDataGenerator(String type, String generator) async {
    try {
      final response = await ApiService.dio.get(
        '/api/writer/generator/${type.toLowerCase()}/${generator.toLowerCase()}',
        options: Options(responseType: ResponseType.stream),
      );

      if (response.statusCode == 200) {
        final stream = response.data.stream as Stream<List<int>>;
        final bytes = <int>[];

        await for (final chunk in stream) {
          bytes.addAll(chunk);
        }

        final fileContent = utf8.decode(
          bytes,
        ); // Puedes usar latin1.decode si no es UTF-8
        return fileContent;
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      throw Exception('Error al obtener el archivo: $e');
    }
  }

  static Future<void> saveDataGenerator(
    String type,
    String generator,
    String content,
  ) async {
    try {
      await ApiService.dio.post(
        '/api/writer/generator/$type/$generator',
        data: {'content': content},
      );
    } catch (e) {
      throw Exception('Error al guardar los datos: $e');
    }
  }

  static Future<void> saveDocument(
    controller,
    documentId,
    documentTitle,
  ) async {
    final json = jsonEncode(controller.document.toDelta().toJson());
    // Aquí llamarías a tu backend o servicio para guardar el documento en MySQL
    await CommonServices.saveDocument(documentId, documentTitle, json);
    // Mostrar confirmación
  }

  static Future<void> createDocument(
    String documentId,
    String title,
    String content,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');
      final response = await ApiService.dio.post(
        '/api/documents/create',
        data: {'documentId': documentId, 'title': title, 'content': content, 'userId': userId},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Error al crear el documento: ${response.data}');
      }
    } catch (e) {
      print('Error al crear el documento: $e');
      throw Exception('No se pudo crear el documento');
    }
  }
}
