import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/user.dart';
import 'package:inkger/frontend/screens/user_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileLoader extends StatefulWidget {
  final User? passedUser;

  const UserProfileLoader({super.key, this.passedUser});

  @override
  State<UserProfileLoader> createState() => _UserProfileLoaderState();
}

class _UserProfileLoaderState extends State<UserProfileLoader> {
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = widget.passedUser != null
        ? Future.value(widget.passedUser)
        : _loadUserFromPrefs();
  }

  Future<User?> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Verificación de campos requeridos
      if (!prefs.containsKey('id') ||
          !prefs.containsKey('username') ||
          !prefs.containsKey('email')) {
        debugPrint('Faltan campos requeridos en SharedPreferences');
        return null;
      }

      // Campos requeridos
      final id = prefs.getInt('id');
      final username = prefs.getString('username');
      final email = prefs.getString('email');

      // Validación de campos no nulos
      if (id == null || username == null || email == null) {
        debugPrint('Campos requeridos son nulos');
        return null;
      }

      // Campos opcionales (incluyendo fechas)
      final name = prefs.getString('name');
      final avatarUrl = prefs.getString('avatarUrl');
      final password = prefs.getString('password');
      final rolesString = prefs.getString('role'); // Recupera como String
      final roles = rolesString != null ? rolesString.split(',') : ['USER'];

      // Manejo seguro de fechas
      DateTime? createdAt;
      DateTime? updatedAt;
      DateTime? lastLogin;

      try {
        final createdAtStr = prefs.getString('createdAt');
        final updatedAtStr = prefs.getString('updatedAt');
        final loggedAtStr = prefs.getString('lastLogin');

        if (createdAtStr != null) {
          createdAt = DateTime.parse(createdAtStr);
        }

        if (updatedAtStr != null) {
          updatedAt = DateTime.parse(updatedAtStr);
        }
        if (loggedAtStr != null) {
          lastLogin = DateTime.parse(loggedAtStr);
        }
      } catch (e) {
        debugPrint('Error parseando fechas: $e');
      }

      return User(
        id: id,
        username: username,
        password: password ?? '',
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        roles: roles,
        createdAt: createdAt,
        updatedAt: updatedAt,
        lastLogin: lastLogin,
      );
    } catch (e) {
      debugPrint('Error cargando usuario desde SharedPreferences: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Error en FutureBuilder: ${snapshot.error}');
          return const Scaffold(
            body: Center(child: Text('Error cargando perfil')),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          debugPrint('Datos de usuario no disponibles');
          return const Scaffold(
            body: Center(child: Text('No se encontraron datos de usuario')),
          );
        }

        return ProfileScreen(user: snapshot.data!);
      },
    );
  }
}
