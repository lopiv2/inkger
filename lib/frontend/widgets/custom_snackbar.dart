import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white), // Texto en blanco para mejor visibilidad
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // Hace que el SnackBar flote sobre la UI
      ),
    );
  }
}
