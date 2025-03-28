import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileImportDialog extends StatefulWidget {
  final PlatformFile file;
  final String initType;

  const FileImportDialog({required this.file, required this.initType, Key? key})
    : super(key: key);

  @override
  _FileImportDialogState createState() => _FileImportDialogState();
}

class _FileImportDialogState extends State<FileImportDialog> {
  late String selectedType;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initType;
  }

  Future<void> _uploadFile() async {
    setState(() => uploading = true);

    try {
      if (widget.file.bytes == null) {
        throw Exception('No se pudo leer el archivo');
      }

      // Obtener el path correspondiente al tipo seleccionado
      final libraryPath = await _getLibraryPath(selectedType.toLowerCase());
      if (libraryPath == null) {
        throw Exception('No se encontró ruta configurada para $selectedType');
      }

      final response = await ApiService.uploadFile(
        fileBytes: widget.file.bytes!,
        fileName: widget.file.name,
        fileType: selectedType.toLowerCase(),
        uploadPath: libraryPath, // Pasamos el path específico
        metadata: {
          'originalName': widget.file.name,
          'size': widget.file.size,
          'uploadDate': DateTime.now().toIso8601String(),
        },
        context: context,
        onSendProgress: (sent, total) {
          debugPrint('Progreso: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );

      _handleResponse(response);
      // Llamar al endpoint para obtener todos los libros
      final allBooksResponse = await BookServices.getAllBooks();
      if (allBooksResponse.statusCode == 200) {
        // Mapear la respuesta de todos los libros a una lista de objetos Book
        final List<Book> booksList =
            (allBooksResponse.data as List)
                .map(
                  (bookData) => Book(
                    id: bookData['id'],
                    title: bookData['title'],
                    author: bookData['author'],
                    publicationDate: DateTime.parse(
                      bookData['publicationDate'],
                    ),
                    creationDate: DateTime.parse(bookData['creationDate']),
                    description: bookData['description'],
                    publisher: bookData['publisher'],
                    language: bookData['language'],
                    coverPath: bookData['coverPath'],
                    identifiers: bookData['identifiers'],
                    tags: bookData['tags'],
                    series: bookData['series'],
                    seriesNumber: bookData['seriesNumber'],
                    read:
                        bookData['read'] ??
                        false, // Si existe el campo "read", usarlo
                    fileSize: bookData['fileSize'],
                    filePath: bookData['filePath'],
                  ),
                )
                .toList();

        // Actualizar la lista de libros en el BooksProvider
        if (mounted) {
          context.read<BooksProvider>().setBooks(booksList);
        }
      } else {
        // Maneja el error si no se pudieron obtener los libros
        print("Error al obtener los libros");
      }
    } catch (e) {
      _showError('Error subiendo archivo: ${e.toString()}');
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<String?> _getLibraryPath(String type) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case 'comic':
        return prefs.getString('comicAppDirectory');
      case 'libro':
      case 'book':
        return prefs.getString('bookAppDirectory');
      case 'audiobook':
        return prefs.getString('audiobookAppDirectory');
      default:
        return null;
    }
  }

  void _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final path = response.data['path'];
      final filename = response.data['filename'];
      _showSuccess('Archivo $filename guardado en: $path');
    } else {
      _showError('Error en el servidor: ${response.statusCode}');
    }
  }

  void _showSuccess(String path) {
    CustomSnackBar.show(
      context,
      'Archivo guardado en: $path',
      Colors.green,
      duration: Duration(seconds: 4),
    );
    Navigator.pop(context, true);
  }

  void _showError(String message) {
    CustomSnackBar.show(
      context,
      message,
      Colors.red,
      duration: Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importar Archivo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Archivo: ${widget.file.name}'),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: selectedType,
            items:
                ['Libro', 'Cómic', 'Audiolibro', 'Otro']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged:
                uploading
                    ? null
                    : (value) => setState(() => selectedType = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: uploading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: uploading ? null : _uploadFile,
          child:
              uploading
                  ? const CircularProgressIndicator()
                  : const Text('Importar'),
        ),
      ],
    );
  }
}
