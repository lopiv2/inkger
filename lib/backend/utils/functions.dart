import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
//import 'package:mime/mime.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelf/shelf.dart';
import 'package:path/path.dart' as p;

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

  // Añade esto al archivo donde tienes tus handlers
  static Future<Response> uploadHandler(
    Request request,
    MySQLConnection conn,
  ) async {
    print('Received upload request at: ${DateTime.now()}');
    print('Request headers: ${request.headers}');
    // More permissive content-type check
    if (request.headers['content-type'] == null ||
        !request.headers['content-type']!.contains('multipart')) {
      return Response(400, body: 'Invalid content type');
    }

    try {
      final boundary = request.headers['content-type']!.split('boundary=').last;
      final body = await request.read().expand((x) => x).toList();
      final parts =
          await MimeMultipartTransformer(
            boundary,
          ).bind(Stream.fromIterable([body])).toList();

      String? fileType;
      List<int>? fileBytes;
      String? fileName;

      for (final part in parts) {
        final header = part.headers['content-disposition'] ?? '';
        final content = await part.fold(
          <int>[],
          (bytes, chunk) => bytes..addAll(chunk),
        );

        if (header.contains('name="tipo"') || header.contains('name="type"')) {
          fileType = utf8.decode(content).trim();
        } else if (header.contains('name="selectedFile"') ||
            header.contains('name="file"')) {
          fileName = _extractFilename(header);
          fileBytes = content;
        }
      }

      // 4. Validaciones
      if (fileType == null || fileBytes == null || fileName == null) {
        return Response(400, body: 'Missing required fields');
      }

      // 5. Obtener conexión MySQL
      await conn.connect();

      // 6. Obtener ruta de destino
      final pathResult = await conn.execute(
        'SELECT path FROM libraries WHERE type = :type LIMIT 1',
        {'type': fileType.toLowerCase()},
      );

      if (pathResult.rows.isEmpty) {
        await conn.close();
        return Response(404, body: 'Library type not configured');
      }

      // 7. Guardar archivo
      final destPath = p.join(
        pathResult.rows.first.colByName('path')!,
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(fileName)}',
      );

      await File(destPath).writeAsBytes(fileBytes);
      await conn.close();

      // 8. Responder
      return Response.ok(
        jsonEncode({'status': 'success', 'path': destPath, 'type': fileType}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  static String _extractFilename(String contentDisposition) {
    final filenameMatch = RegExp(
      'filename="(.*)"',
    ).firstMatch(contentDisposition);
    return filenameMatch?.group(1) ?? 'unnamed_file';
  }
}
