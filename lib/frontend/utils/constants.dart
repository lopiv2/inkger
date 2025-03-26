import 'dart:io';
import 'package:logging/logging.dart';

class Constants {
  // Detectar la unidad de instalación del proyecto
  static final String unitDrive = _detectUnitDrive();
  static final String ApiIP="localhost";

  // Rutas predeterminadas para archivos
  static final String comicsPath = '$unitDrive/Inkger/data/comics';
  static final String booksPath = '$unitDrive/Inkger/data/books';
  static final String audiobooksPath = '$unitDrive/Inkger/data/audiobooks';

  // Rutas para Docker (opcional)
  static const String dockerComicsPath = '/app/data/comics';
  static const String dockerBooksPath = '/app/data/books';
  static const String dockerAudiobooksPath = '/app/data/audiobooks';

  static var logger = Logger('InkgerServer');

  /// Obtiene la unidad donde está ubicado el proyecto
  static String _detectUnitDrive() {
    try {
      String path = Platform.script.toFilePath();
      if (Platform.isWindows) {
        return path.substring(0, 2); // Ejemplo: "C:"
      } else {
        return '/'; // En Linux y Mac, raíz del sistema
      }
    } catch (e) {
      logger.severe('Error detectando la unidad del proyecto: $e');
      return 'C:'; // Fallback en Windows
    }
  }
}
