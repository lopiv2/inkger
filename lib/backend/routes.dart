import 'package:inkger/frontend/utils/constants.dart';
import 'package:shelf/shelf.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:bcrypt/bcrypt.dart';
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf_router/shelf_router.dart';

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
Future<Response> getLibraries(MySQLConnection conn) async {
  try {
    final result = await conn.execute('SELECT * FROM libraries');

    final libraries = result.rows.map((row) {
      return {
        'id': row.assoc()['id'],
        'type': row.assoc()['type'],
        'path': row.assoc()['path'],
      };
    }).toList();

    return Response.ok(
      jsonEncode(libraries),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
  } catch (e) {
    print('Error al obtener bibliotecas: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Error interno'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Función para actualizar una biblioteca
Future<Response> updateLibrary(Request request, MySQLConnection conn) async {
  try {
    final body = await request.readAsString();
    Constants.logger.info('Body of the application: $body');

    final data = jsonDecode(body) as Map<String, dynamic>;
    final id = data['id'];
    final path = data['path'];

    await conn.execute(
      'UPDATE libraries SET path = :path WHERE id = :id',
      {'path': path, 'id': id},
    );

    return Response.ok(
      jsonEncode({'message': 'Ruta actualizada correctamente'}),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
  } catch (e) {
    Constants.logger.info('Error updating library: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Error interno'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Función para definir todas las rutas
Handler setupRoutes(MySQLConnection conn) {
  final router = Router();

  // Ruta de login
  router.post('/api/login', (Request request) => handleLogin(request, conn));

  // Ruta para obtener las bibliotecas
  router.get('/api/libraries', (Request request) => getLibraries(conn));

  // Ruta para actualizar una biblioteca
  router.post('/api/libraries', (Request request) => updateLibrary(request, conn));

  // Ruta por defecto (no encontrada)
  router.all('/<ignored|.*>', (Request request) {
    return Response.notFound('Ruta no encontrada');
  });

  return router;
}