import 'dart:io';

import 'package:inkger/backend/routes.dart';
import 'package:inkger/backend/services/library_services.dart';
import 'package:inkger/frontend/utils/constants.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:mysql_client/mysql_client.dart';

import 'package:shelf_cors_headers/shelf_cors_headers.dart';


void main() async {
  Logger.root.level = Level.ALL; // Nivel de log
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  Constants.logger.info('Iniciando servidor...');
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

  // Crear carpetas si no existen
  await _createDirectories();

  // Crear una instancia del servicio
  final libraryService = LibraryService(conn);

  // Configurar las rutas
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(setupRoutes(conn)); // Usa setupRoutes para definir las rutas

  // Iniciar el servidor
  final server = await io.serve(handler, 'localhost', 3000);
  Constants.logger.info('Servidor backend corriendo en http://localhost:3000');
}

Future<void> _createDirectories() async {
  // Verificar y crear la carpeta de comics
  final comicsDir = Directory(Constants.comicsPath);
  if (!await comicsDir.exists()) {
    await comicsDir.create(recursive: true);
    Constants.logger.info('Carpeta de comics creada: ${comicsDir.path}');
  }

  // Verificar y crear la carpeta de libros
  final booksDir = Directory(Constants.booksPath);
  if (!await booksDir.exists()) {
    await booksDir.create(recursive: true);
    Constants.logger.info('Book folder created: ${booksDir.path}');
  }

  // Verificar y crear la carpeta de audiolibros
  final audiobooksDir = Directory(Constants.audiobooksPath);
  if (!await audiobooksDir.exists()) {
    await audiobooksDir.create(recursive: true);
    Constants.logger.info('Audiobook folder created: ${audiobooksDir.path}');
  }
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

  await conn.execute('''
    CREATE TABLE IF NOT EXISTS libraries (
      id INT AUTO_INCREMENT PRIMARY KEY,
      type ENUM('comics', 'books', 'audiobooks') NOT NULL,
      path VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  ''');

  // Insertar rutas predeterminadas (Windows)
  await conn.execute('''
    INSERT INTO libraries (type, path)
    VALUES ('comics', '${Constants.comicsPath}'),
           ('books', '${Constants.booksPath}'),
           ('audiobooks', '${Constants.audiobooksPath}')
    ON DUPLICATE KEY UPDATE path = VALUES(path);
  ''');

  Constants.logger.info('Tables verified/created correctly');
}
