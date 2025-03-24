import 'package:inkger/frontend/utils/constants.dart';
import 'package:logging/logging.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:bcrypt/bcrypt.dart';

class DatabaseHelper {
  static MySQLConnection? _connection;

  static Future<void> initializeDatabase() async {
    try {
      _connection = await MySQLConnection.createConnection(
        host: 'localhost',
        port: 3306,
        userName: 'root',
        password: 'root',
      );

      await _connection!.connect();

      // Crear la base de datos si no existe
      await _connection!.execute("CREATE DATABASE IF NOT EXISTS inkger;");
      await _connection!.execute("USE inkger;");

      // Crear tablas si no existen
      await _createTables();

      // Insertar usuario admin por defecto
      await _insertDefaultAdmin();

      Constants.logger.info(
        'Base de datos y tablas verificadas/creadas correctamente.',
      );
    } catch (e) {
      Constants.logger.severe('Error al conectar con la base de datos: $e');
    }
  }

  static MySQLConnection? get connection => _connection;

  static Future<void> _createTables() async {
    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS libraries (
        id INT AUTO_INCREMENT PRIMARY KEY,
        type ENUM('comics', 'books', 'audiobooks') NOT NULL,
        path VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Insertar rutas predeterminadas
    await _connection!.execute('''
  INSERT INTO libraries (type, path)
  SELECT * FROM (SELECT 'comics', '${Constants.comicsPath}') AS tmp
  WHERE NOT EXISTS (SELECT 1 FROM libraries WHERE type = 'comics') LIMIT 1;
''');

    await _connection!.execute('''
  INSERT INTO libraries (type, path)
  SELECT * FROM (SELECT 'books', '${Constants.booksPath}') AS tmp
  WHERE NOT EXISTS (SELECT 1 FROM libraries WHERE type = 'books') LIMIT 1;
''');

    await _connection!.execute('''
  INSERT INTO libraries (type, path)
  SELECT * FROM (SELECT 'audiobooks', '${Constants.audiobooksPath}') AS tmp
  WHERE NOT EXISTS (SELECT 1 FROM libraries WHERE type = 'audiobooks') LIMIT 1;
''');
  }

  static Future<void> _insertDefaultAdmin() async {
    // Verificar si el usuario admin ya existe
    var result = await _connection!.execute(
      "SELECT COUNT(*) as count FROM users WHERE username = 'admin';",
    );
    var count = int.parse(result.rows.first.colByName('count')!);

    if (count == 0) {
      // Hashear la contraseña
      String hashedPassword = BCrypt.hashpw('password123', BCrypt.gensalt());

      // Insertar usuario admin
      await _connection!.execute('''
        INSERT INTO users (username, password) VALUES ('admin', '$hashedPassword');
      ''');
      Constants.logger.info('Usuario admin creado con éxito.');
    } else {
      Constants.logger.info('El usuario admin ya existe.');
    }
  }
}
