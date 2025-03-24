import 'dart:io';
import 'package:inkger/backend/routes.dart';
import 'package:inkger/backend/services/database_helper_service.dart';
import 'package:inkger/backend/services/library_services.dart';
import 'package:inkger/frontend/utils/constants.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

void main() async {
  Logger.root.level = Level.ALL; // Nivel de log
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  Constants.logger.info('Iniciando servidor...');

  // Inicializar base de datos
  await DatabaseHelper.initializeDatabase();
  final conn = DatabaseHelper.connection;
  
  if (conn == null) {
    Constants.logger.severe("Error: No se pudo conectar a la base de datos.");
    return;
  }

  // Crear una instancia del servicio
  final libraryService = LibraryService(conn);

  // Crear carpetas si no existen
  await _createDirectories();

  // Configurar las rutas
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(setupRoutes(conn));

  // Iniciar el servidor
  final server = await io.serve(handler, 'localhost', 3000);
  Constants.logger.info('Servidor backend corriendo en http://localhost:3000');
}

Future<void> _createDirectories() async {
  final directories = {
    'comics': Constants.comicsPath,
    'books': Constants.booksPath,
    'audiobooks': Constants.audiobooksPath,
  };

  for (var entry in directories.entries) {
    final dir = Directory(entry.value);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      Constants.logger.info('Carpeta de ${entry.key} creada: ${dir.path}');
    }
  }
}