import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class LibraryServices {
  static Future<String> loadLibraryPath(String libraryId) async {
    try {
      final response = await ApiService.dio.get(
        '/api/libraries/$libraryId/path',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        if (response.data is String &&
            response.data.contains('<!DOCTYPE html>')) {
          throw Exception('El backend no está respondiendo correctamente');
        }

        final data = response.data as Map<String, dynamic>;
        return data['path'] ?? ''; // Devolver la ruta obtenida
      } else {
        throw Exception(
          'Error ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } catch (e) {
      print('Error cargando la ruta: $e');
      return ''; // En caso de error, devolver una cadena vacía
    }
  }

  // Método para actualizar la ruta en la API y mostrar un SnackBar
  static Future<void> updateLibraryPath(
    BuildContext context,
    String libraryId,
    String newPath,
  ) async {
    try {
      final prefsProvider = context.read<PreferencesProvider>();

      // Llamada al backend para actualizar la ruta
      final response = await ApiService.dio.put(
        '/api/libraries/$libraryId',
        data: jsonEncode({'path': newPath}),
      );

      if (response.statusCode == 200) {
        // Actualizar la ruta en SharedPreferences según el tipo de librería
        switch (libraryId) {
          case 'comics':
            await prefsProvider.setComicDirectory(newPath);
            break;
          case 'books':
            await prefsProvider.setBookDirectory(newPath);
            break;
          case 'audiobooks':
            await prefsProvider.setAudiobookDirectory(newPath);
            break;
        }

        CustomSnackBar.show(
          context,
          'Ruta actualizada correctamente',
          Colors.green,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      CustomSnackBar.show(
        context,
        'Error al actualizar: ${e.toString()}',
        Colors.red,
        duration: Duration(seconds: 4),
      );
    }
  }
}
