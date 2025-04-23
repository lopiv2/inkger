import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonServices {

  static Future<int> fetchAudioBookCount() async {
    final response = await ApiService.dio.get(
      '/api/count-audiobooks',
      options: Options(
        responseType: ResponseType.json,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      // Suponiendo que la respuesta de la API es un JSON con un campo "count"
      final data = json.decode(response.data);
      return data['count']; // Cambia 'count' por el campo correcto en la respuesta
    } else {
      throw Exception('Failed to load audiobooks count');
    }
  }

  static Future<int> fetchBookCount() async {
    final response = await ApiService.dio.get(
      '/api/count-books',
      options: Options(
        responseType: ResponseType.json,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      return response.data['count']; // Cambia 'count' por el campo correcto en la respuesta
    } else {
      throw Exception('Failed to load book count');
    }
  }

  static Future<int> fetchComicCount() async {
    final response = await ApiService.dio.get(
      '/api/count-comics',
      options: Options(
        responseType: ResponseType.json,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      return response.data['count']; // Cambia 'count' por el campo correcto en la respuesta
    } else {
      throw Exception('Failed to load comic count');
    }
  }

  static Future<Map<String, int>> fetchDocumentFormatsCount() async {
    try {
      final response = await ApiService.dio.get(
      '/api/count-document-formats',
      options: Options(
        responseType: ResponseType.json,
        validateStatus: (status) => status! < 500,
      ),
    );

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, parseamos el JSON
        final data = response.data;
        return Map<String, int>.from(data['count']);
      } else {
        throw Exception('Failed to load document formats');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<int> fetchSeriesCount() async {
    final response = await ApiService.dio.get(
      '/api/count-series',
      options: Options(
        responseType: ResponseType.json,
        validateStatus: (status) => status! < 500,
      ),
    );
    if (response.statusCode == 200) {
      // Suponiendo que la respuesta de la API es un JSON con un campo "count"
      return response.data['count']; // Cambia 'count' por el campo correcto en la respuesta
    } else {
      throw Exception('Failed to load series count');
    }
  }

  static Future<Uint8List?> getCover(String coverPath) async {
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

  static Future<Uint8List> getProxyImageBytes(String originalUrl) async {
    try {
      final response = await ApiService.dio.get(
        "/api/proxy",
        queryParameters: {"url": originalUrl},
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      print("Error al obtener imagen: $e");
      throw Exception("No se pudo cargar la imagen");
    }
  }

  static Future<void> loadSettingsToSharedPrefs() async {
    final response = await ApiService.dio.get(
      '/api/settings',
      options: Options(
        responseType: ResponseType.json,
        validateStatus: (status) => status! < 500,
      ),
    );
    if (response.statusCode == 200) {
      final List settings = response.data;
      final prefs = await SharedPreferences.getInstance();
      for (var setting in settings) {
        prefs.setString(setting['key'], setting['value']);
      }
    }
  }

  static Future<Response> saveMultipleSettingsToSharedPrefs(
    SharedPreferences prefs,
    List<Map<String, dynamic>> settings,
  ) async {
    print(settings);
    final response = await ApiService.dio.put(
      '/api/settings',
      data: jsonEncode({'settings': settings}),
      options: Options(
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Si la respuesta fue exitosa, guarda los valores localmente
    if (response.statusCode == 200) {
      for (var setting in settings) {
        final key = setting['key'];
        final value = setting['value'];

        if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        }
      }
    }

    return response;
  }

  static double calculateAspectRatio(crossAxisCount) =>
      0.6 + (0.1 * (10 - crossAxisCount));
  static num calculateMainAxisExtent(crossAxisCount) =>
      150 + (100 * (10 - crossAxisCount));
  static double calculateItemHeight(crossAxisCount) =>
      calculateMainAxisExtent(crossAxisCount) * 0.7;
  static double calculateTextSize(crossAxisCount) =>
      (8 + (2 * (8 - crossAxisCount))).toDouble();
}
