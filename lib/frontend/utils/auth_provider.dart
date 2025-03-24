// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  DateTime? _tokenExpiration;
  bool _isLoading = false;

  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && 
      (_tokenExpiration?.isAfter(DateTime.now()) ?? false);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _tokenExpiration = DateTime.tryParse(prefs.getString('token_expiration') ?? '');
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Aquí iría tu llamada real a la API
      await Future.delayed(Duration(seconds: 1)); // Simulación
      
      // Datos simulados de respuesta
      final mockResponse = {
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'expiresIn': 3600 // 1 hora
      };

      _token = mockResponse['token'] as String;
      _tokenExpiration = DateTime.now().add(
        Duration(seconds: mockResponse['expiresIn'] as int)
      );

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('token_expiration', _tokenExpiration!.toIso8601String());

    } catch (e) {
      _token = null;
      _tokenExpiration = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _tokenExpiration = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('token_expiration');
    
    notifyListeners();
  }

  Future<String?> getValidToken() async {
    if (isAuthenticated) return _token;
    
    // Opcional: Intentar renovar el token aquí
    return null;
  }
}