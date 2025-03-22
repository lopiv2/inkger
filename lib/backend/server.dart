import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:bcrypt/bcrypt.dart';
import 'dart:convert';

void main() async {
  // Conectar a MySQL
  final conn = await MySQLConnection.createConnection(
    host: 'localhost',
    port: 3306,
    userName: 'root',
    password: 'root', // Contraseña vacía
    databaseName: 'inkger',
  );

  await conn.connect();

  // Crear tablas si no existen
  await _createTables(conn);

  // Definir el manejador de rutas (_router)
  Future<Response> _router(Request request) async {
    if (request.method == 'POST' && request.url.path == '/api/login') {
      return await _handleLogin(request, conn);
    }
    return Response.notFound('Ruta no encontrada');
  }

  // Iniciar el servidor
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router);

  final server = await io.serve(handler, 'localhost', 3000);
  print('Servidor backend corriendo en http://localhost:3000');
}

Future<void> _createTables(MySQLConnection conn) async {
  await conn.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      username VARCHAR(50) NOT NULL UNIQUE,
      password VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  ''');
  print('Tablas verificadas/creadas correctamente');
}

Future<Response> _handleLogin(Request request, MySQLConnection conn) async {
  try {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final username = data['username'];
    final password = data['password'];

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