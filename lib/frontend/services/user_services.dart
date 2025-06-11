import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/models/user.dart';

class UserServices {
  // Función para actualizar la contraseña del usuario
  static Future<bool> updatePassword(int userId, String newPassword) async {
    try {
      final response = await ApiService.dio.put(
        '/api/users/$userId/password',
        data: {
          'newPassword': newPassword,
        },
      );
      // Verificar que la respuesta sea exitosa
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error al actualizar la contraseña: $e');
      return false;
    }
  }

  // Función para actualizar los otros datos del usuario (nombre, email, etc.)
  static Future<bool> updateUserData(int userId, String username, String email, String name, {String? role}) async {
    try {
      final data = {
        'username': username,
        'email': email,
        'name': name,
      };

      if (role != null) {
        data['role'] = role;
      }

      final response = await ApiService.dio.put(
        '/api/users/$userId',
        data: data,
      );

      // Verificar que la respuesta sea exitosa
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error al actualizar los datos del usuario: $e');
      return false;
    }
  }

  // Función para obtener los datos del usuario (para obtener los detalles antes de actualizar)
  static Future<User?> getUserDetails(int userId) async {
    try {
      final response = await ApiService.dio.get('/api/users/$userId');
      if (response.statusCode == 200) {
        final data = response.data;
        return User.fromJson(data); // Asumiendo que tienes un método `fromJson` en tu clase `User`
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error al obtener los detalles del usuario: $e');
      return null;
    }
  }
  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final response = await ApiService.dio.get('/api/users');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error al obtener usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el backend: $e');
    }
  }

  static Future<bool> deleteUser(int userId) async {
    try {
      final response = await ApiService.dio.delete('/api/users/$userId');

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Error al eliminar usuario: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error al conectar con el backend: $e');
      return false;
    }
  }
}