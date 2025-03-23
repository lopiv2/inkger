import 'package:logging/logging.dart';

class Constants {
  // Rutas predeterminadas para Windows
  static const String unitDrive="G:";
  static const String comicsPath = '$unitDrive/Inkger/data/comics';
  static const String booksPath = '$unitDrive/Inkger/data/books';
  static const String audiobooksPath = '$unitDrive/Inkger/data/audiobooks';

  // Rutas predeterminadas para Docker (opcional)
  static const String dockerComicsPath = '/app/data/comics';
  static const String dockerBooksPath = '/app/data/books';
  static const String dockerAudiobooksPath = '/app/data/audiobooks';

  static var logger = Logger('InkgerServer');
}