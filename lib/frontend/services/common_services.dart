import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonServices {
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

  static Future<Response> saveSettingsToSharedPrefs(
    SharedPreferences prefs,
    Map<String, dynamic> body,
  ) async {
    final response = await ApiService.dio.put(
      '/api/settings',
      data: jsonEncode(body),
      options: Options(
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Si la respuesta fue exitosa, guarda el valor localmente
    if (response.statusCode == 200) {
      await prefs.setString('Comicvine Key', body['value']);
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
