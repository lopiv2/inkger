import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/models/event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventServices {
  static Future<void> deleteEvent(Event event) async {
    try {
      // 1. Llamar a la API para eliminar el comic
      final response = await ApiService.dio.delete('/api/events/${event.id}');

      if (response.statusCode == 200) {
        debugPrint("Evento eliminado correctamente: ${event.title}");
      } else {
        debugPrint("Error al eliminar el evento: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error eliminando el evento: $e");
    }
  }

  static Future<List<dynamic>?> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    try {
      final response = await ApiService.dio.get('/api/events/$userId');
      final List data = response.data;
      return data;
    } catch (e) {
      debugPrint('Error cargando eventos: $e');
      return null;
    }
  }

  static Future<void> updateEvent(Event event) async {
    try {
      final response = await ApiService.dio.put(
        '/api/events/${event.id}',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'title': event.title,
          'date': event.date.toIso8601String(),
          'description': event.description,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint("Evento actualizado correctamente");
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Response?> saveEvent(Event event) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    final response = await ApiService.dio.post(
      '/api/events/save-event', // Ajusta según tu endpoint
      data: {
        'date': event.date.toIso8601String(),
        'title': event.title,
        'userId': userId,
        'description': event.description,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode == 201) {
      debugPrint('Evento guardado exitosamente');
      return response;
    } else {
      debugPrint('Error al guardar evento: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    debugPrint('Error al enviar evento: $e');
    return null; // <- Añadido para evitar retorno implícito de `void`
  }
}
}
