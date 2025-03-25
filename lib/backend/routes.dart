import 'dart:io';

import 'package:inkger/backend/services/database_helper_service.dart';
import 'package:inkger/frontend/utils/constants.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:bcrypt/bcrypt.dart';
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as p;

// Función para manejar el login
Future<Response> handleLogin(Request request, MySQLConnection conn) async {
  try {
    final body = await request.readAsString();
    print('Cuerpo de la solicitud: $body');

    final data = jsonDecode(body) as Map<String, dynamic>;
    final username = data['username'];
    final password = data['password'];

    print('Credenciales recibidas: username=$username, password=$password');

    final result = await conn.execute(
      'SELECT id, password FROM users WHERE username = :username',
      {'username': username},
    );

    if (result.rows.isEmpty) {
      return Response.unauthorized('Credenciales inválidas');
    }

    final user = result.rows.first;
    final storedHash = user.assoc()['password'];

    if (!BCrypt.checkpw(password, storedHash!)) {
      return Response.unauthorized('Credenciales inválidas');
    }

    final jwt = JWT({'userId': user.assoc()['id'], 'username': username});
    final token = jwt.sign(SecretKey('tu_clave_secreta'));

    return Response.ok(
      jsonEncode({'token': token}),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
  } catch (e) {
    print('Error en login: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Error interno'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Función para obtener las bibliotecas
Future<Response> getLibraryPaths(Request request) async {
  final conn = DatabaseHelper.connection;
  if (conn == null) {
    return Response.internalServerError(
      body: 'Error de conexión con la base de datos',
    );
  }

  final result = await conn.execute('''
    SELECT 
      (SELECT path FROM libraries WHERE type = 'comics' LIMIT 1) AS comicPath,
      (SELECT path FROM libraries WHERE type = 'books' LIMIT 1) AS bookPath,
      (SELECT path FROM libraries WHERE type = 'audiobooks' LIMIT 1) AS audioPath;
  ''');

  if (result.numOfRows == 0) {
    return Response.notFound('No se encontraron rutas');
  }

  final row = result.rows.first;
  final data = {
    'comicPath': row.colByName('comicPath') ?? '',
    'bookPath': row.colByName('bookPath') ?? '',
    'audioPath': row.colByName('audioPath') ?? '',
  };

  return Response.ok(
    jsonEncode(data),
    headers: {'Content-Type': 'application/json'},
  );
}

// Función para actualizar una biblioteca
// Función actualizada para recibir el tipo
Future<Response> updateLibrary(
  Request request,
  MySQLConnection conn,
  String type,
) async {
  try {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final path = data['path'];

    await conn.execute('UPDATE libraries SET path = :path WHERE type = :type', {
      'path': path,
      'type': type,
    });

    return Response.ok(
      jsonEncode({'message': 'Ruta actualizada correctamente'}),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
  } catch (e) {
    Constants.logger.warning('Error al actualizar la biblioteca: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Error interno'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Función para obtener la ruta de una biblioteca específica
Future<Response> getLibraryPath(
  Request request,
  MySQLConnection conn,
  String id,
) async {
  try {
    final result = await conn.execute(
      'SELECT path FROM libraries WHERE type = :id',
      {'id': id},
    );

    if (result.rows.isEmpty) {
      return Response.notFound('Biblioteca no encontrada');
    }

    final path = result.rows.first.assoc()['path'];

    return Response.ok(
      jsonEncode({'path': path}),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
  } catch (e) {
    print('Error al obtener la ruta: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Error interno'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> uploadHandler(Request request, MySQLConnection conn) async {
  //print('Received upload request at: ${DateTime.now()}');
  //print('Request headers: ${request.headers}');
  // More permissive content-type check
  if (request.headers['content-type'] == null ||
      !request.headers['content-type']!.contains('multipart')) {
    return Response(400, body: 'Invalid content type');
  }

  try {
    final boundary = request.headers['content-type']!.split('boundary=').last;
    final body = await request.read().expand((x) => x).toList();
    //print("Received ${body.length} bytes");
    final parts =
        await MimeMultipartTransformer(
          boundary,
        ).bind(Stream.fromIterable([body])).toList();
    //print("Extracted ${parts.length} parts from multipart data");

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
  } catch (e,stackTrace) {
    print("💥 CRITICAL ERROR:");
    print(e);
    print(stackTrace);
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

String _extractFilename(String contentDisposition) {
  final filenameMatch = RegExp(
    'filename="(.*)"',
  ).firstMatch(contentDisposition);
  return filenameMatch?.group(1) ?? 'unnamed_file';
}

// Función para definir todas las rutas
Handler setupRoutes(MySQLConnection conn) {
  final router = Router();

  // Agrega esta nueva ruta GET con parámetro de ID
  router.get('/api/libraries/<id>/path', (Request request, String id) async {
    return getLibraryPath(request, conn, id);
  });

  // Ruta de login
  router.post('/api/login', (Request request) => handleLogin(request, conn));

  // Ruta para obtener las bibliotecas
  router.get('/api/libraries', (Request request) => getLibraryPaths(request));

  // Ruta para actualizar una biblioteca
  router.put('/api/libraries/<id>', (Request request, String id) async {
    return updateLibrary(request, conn, id);
  });

  // Añade esta línea para el upload
  router.post('/api/upload', (Request request) => uploadHandler(request, conn));

  // Ruta por defecto (no encontrada)
  router.all('/<ignored|.*>', (Request request) {
    return Response.notFound('Ruta no encontrada');
  });

  return router;
}
