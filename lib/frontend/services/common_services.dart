import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:inkger/backend/services/api_service.dart';

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

  static double calculateAspectRatio(crossAxisCount) => 0.6 + (0.1 * (10 - crossAxisCount));
  static num calculateMainAxisExtent(crossAxisCount) => 150 + (100 * (10 - crossAxisCount));
  static double calculateItemHeight(crossAxisCount) => calculateMainAxisExtent(crossAxisCount) * 0.7;
  static double calculateTextSize(crossAxisCount) => (8 + (2 * (8 - crossAxisCount))).toDouble();
}
