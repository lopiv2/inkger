import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:inkger/backend/services/api_service.dart';

class WriterServices {
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
}
