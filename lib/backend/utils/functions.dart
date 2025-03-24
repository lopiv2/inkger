import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Functions {
  static handleLogout(bool mounted, BuildContext context) {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
