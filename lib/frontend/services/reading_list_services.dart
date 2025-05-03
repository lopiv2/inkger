import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inkger/frontend/models/reading_list.dart';
import 'package:inkger/frontend/models/reading_list_item.dart';

class ReadingListServices {
  static Future<Response> createReadingList(Map<String, dynamic> data) async {
    try {
      Response response = await ApiService.dio.post(
        '/api/reading-list',
        data: data,
      );
      return response;
    } catch (e) {
      print('Error al crear la lista de lectura: $e');
      rethrow;
    }
  }

  static Future<List<String>> fetchItemCovers(List<ReadingListItem> items) async {
    try {
      // Obtener los primeros 4 elementos
      final limitedItems = items.take(4).toList();

      // Construir la lista de parámetros para la API
      final List<Map<String, dynamic>> queryParams = limitedItems.map((item) {
        return {'itemId': item.itemId, 'type': item.type};
      }).toList();

      // Llamar a la API
      final response = await ApiService.dio.post('/api/get-item-covers', data: {'items': queryParams});
      //print(response.data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        // Extraer las URLs de las portadas
        final List<dynamic> covers = response.data['covers'];
        return covers.cast<String>();
      } else {
        throw Exception('Error al obtener las portadas: ${response.data['error'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      debugPrint('Error al obtener las portadas: $e');
      return [];
    }
  }

  static Future<List<ReadingList>> getReadingLists() async {
    try {
      Response response = await ApiService.dio.get('/api/reading-list');
      // Verifica si la respuesta contiene datos válidos.
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        // Verifica si la lista no está vacía.
        if (data.isEmpty) {
          print('La lista de lectura está vacía.');
          return [];
        }

        // Mapear cada elemento de la lista al modelo ReadingList
        return data.map((json) {
          return ReadingList(
            title: json['title'],
            missingTitles: json['missingItems'],
            coverUrl: json['coverUrl'],
            items: (json['items'] as List<dynamic>).map((item) {
              return ReadingListItem(
                id: item['id'].toString(), // Convertir a String
                readingListId: item['readingListId'].toString(), // Convertir a String
                type: item['type'],
                title: item['title'],
                series: item['series'],
                orderNumber: item['orderNumber'],
                itemId: item['itemId'].toString(), // Convertir a String
                number: '',
                volume: '',
                year: '',
              );
            }).toList(),
          );
        }).toList();
      } else {
        throw Exception(
          'Error al obtener las listas de lectura: Respuesta inválida',
        );
      }
    } catch (e) {
      print('Error al obtener las listas de lectura: $e');
      rethrow;
    }
  }

  static Future<Response> updateReadingList(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      Response response = await ApiService.dio.put(
        '/api/reading-list/$id',
        data: data,
      );
      return response;
    } catch (e) {
      print('Error al actualizar la lista de lectura: $e');
      rethrow;
    }
  }

  static Future<Response> deleteReadingList(String id) async {
    try {
      Response response = await ApiService.dio.delete('/api/reading-list/$id');
      return response;
    } catch (e) {
      print('Error al eliminar la lista de lectura: $e');
      rethrow;
    }
  }

  static Future<ReadingList> importReadingList(PlatformFile file) async {
    try {
      // Usar los bytes directamente desde el archivo seleccionado
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });

      Response response = await ApiService.dio.post(
        '/api/import-reading-list',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Validar y limpiar datos antes de mapearlos
        final data = response.data['data'] ?? {};
        final sanitizedData = _sanitizeData(data);

        try {
          // Mapear los datos al modelo ReadingList
          return ReadingList.fromJson(sanitizedData);
        } catch (e) {
          print('Error al mapear los datos a ReadingList: $e');
          throw Exception('Error al mapear los datos a ReadingList');
        }
      } else {
        throw Exception(
          'Error al importar la lista: ${response.data['error'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      print('Error al importar la lista de lectura: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getLibraryItems() async {
    try {
      Response response = await ApiService.dio.get('/api/library-items');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final items = response.data['data'] as List<dynamic>;
        return items.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(
          'Error al obtener los elementos de la biblioteca: ${response.data['error'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      debugPrint('Error al obtener los elementos de la biblioteca: $e');
      rethrow;
    }
  }

  static Future<Response> sendReadingList(
    Map<String, dynamic> readingListJson,
  ) async {
    try {
      //print (readingListJson);
      Response response = await ApiService.dio.post(
        '/api/reading-list', // Reemplazar con la ruta correcta de la API
        data: readingListJson,
      );
      return response;
    } catch (e) {
      print('Error al enviar la lista de lectura: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    // Reemplazar valores nulos por valores predeterminados y manejar estructuras anidadas
    return data.map((key, value) {
      if (value == null) {
        if (key == 'id') {
          return MapEntry(
            key,
            'default-id',
          ); // Asignar un valor predeterminado si falta "id"
        }
        if (key == 'name') {
          return MapEntry(
            key,
            'Sin nombre',
          ); // Valor predeterminado para "name"
        }
        if (key == 'items' || key == 'books') {
          return MapEntry(
            key,
            [],
          ); // Valor predeterminado para "items" o "books"
        }
        return MapEntry(key, ''); // Reemplazar otros nulos por cadenas vacías
      } else if (value is List) {
        // Sanitizar listas anidadas
        return MapEntry(
          key,
          value.map((item) {
            if (item is Map<String, dynamic>) {
              return _sanitizeData(
                item,
              ); // Recursión para sanitizar mapas dentro de listas
            }
            return item ??
                ''; // Reemplazar valores nulos en listas por cadenas vacías
          }).toList(),
        );
      } else if (value is Map<String, dynamic>) {
        // Sanitizar mapas anidados
        return MapEntry(key, _sanitizeData(value));
      }
      return MapEntry(key, value);
    });
  }
}
