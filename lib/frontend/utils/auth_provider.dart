import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  DateTime? _tokenExpiry;
  bool _isAuthenticated = false;

  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String username, String password) async {
    try {
      final response = await ApiService.post(
        '/api/auth/login',
        data: {'username': username, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _token = response.data['token'];
      _isAuthenticated = true;
      _tokenExpiry = _getExpiryFromToken(_token!);
      await _saveAuthData(response.data['user']);
      notifyListeners();
    } catch (e) {
      _clearAuthData();
      rethrow;
    }
  }

  // AÑADE ESTE MÉTODO PARA LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && isTokenValid(token)) {
      _token = token;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    _clearAuthData();
    return false;
  }

  Future<void> _saveAuthData(data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token!);
    await prefs.setString('auth_expiry', _tokenExpiry!.toIso8601String());
    await prefs.setInt('id', data['id']);
    await prefs.setString('name', data['name']);
    await prefs.setString('username', data['username']);
    await prefs.setString('password', data['password']);
    await prefs.setString('avatarUrl', data['avatarUrl']);
    await prefs.setString('email', data['email']);
    await prefs.setString('role', data['role']);
    // Manejo seguro de fechas
    await saveDateTime(prefs, 'createdAt', data['createdAt']);
    await saveDateTime(prefs, 'updatedAt', data['updatedAt']);
    await saveDateTime(prefs, 'lastLogin', data['lastLogin']);
  }


  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_expiry');
    _token = null;
    _tokenExpiry = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  DateTime _getExpiryFromToken(String token) {
    try {
      // 1. Dividir el token JWT
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token JWT inválido');
      }

      // 2. Obtener el payload (parte central)
      var payload = parts[1];

      // 3. Añadir relleno Base64 si es necesario
      final paddingLength = payload.length % 4;
      if (paddingLength > 0) {
        payload += '=' * (4 - paddingLength);
      }

      // 4. Decodificar
      final decoded = utf8.decode(base64Url.decode(payload));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // 5. Obtener timestamp de expiración
      final expiryTimestamp = payloadMap['exp'] as int;
      return DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);
    } catch (e) {
      debugPrint('Error al decodificar token: $e');
      return DateTime.now().subtract(const Duration(days: 1)); // Token inválido
    }
  }

  bool isTokenValid(String token) {
    try {
      final expiry = _getExpiryFromToken(token);
      return expiry.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}
