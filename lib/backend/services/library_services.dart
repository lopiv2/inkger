import 'package:mysql_client/mysql_client.dart';

class LibraryService {
  final MySQLConnection _conn;

  LibraryService(this._conn);

  // Método para obtener la ruta de una biblioteca
  Future<String?> getLibraryPath(int libraryId) async {
    try {
      final result = await _conn.execute(
        'SELECT path FROM libraries WHERE id = :id',
        {'id': libraryId},
      );

      if (result.rows.isNotEmpty) {
        return result.rows.first.assoc()['path'];
      }
      return null;
    } catch (e) {
      print('Error al obtener la ruta de la biblioteca: $e');
      throw Exception('Error al obtener la ruta de la biblioteca');
    }
  }

  // Método para actualizar la ruta de una biblioteca
  Future<void> updateLibraryPath(int libraryId, String newPath) async {
    try {
      await _conn.execute(
        'UPDATE libraries SET path = :path WHERE id = :id',
        {'path': newPath, 'id': libraryId},
      );
      print('Ruta actualizada correctamente');
    } catch (e) {
      print('Error al actualizar la ruta: $e');
      throw Exception('Error al actualizar la ruta');
    }
  }
}