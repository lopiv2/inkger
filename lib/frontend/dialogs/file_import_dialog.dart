import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
import 'package:inkger/l10n/app_localizations.dart';
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
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('id');

      // Actualización optimizada
      if (!mounted) return;

      if (widget.initType == 'book') {
        final provider = Provider.of<BooksProvider>(context, listen: false);
        context.go('/books');
        await provider.loadBooks(id ?? 0); // Espera a que se completen
      }
      if (widget.initType == 'comic') {
        final provider = Provider.of<ComicsProvider>(context, listen: false);
        context.go('/comics');
        await provider.loadcomics(
          prefs.getInt('id') ?? 0,
        ); // Espera a que se completen
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Libro subido y lista actualizada'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<String?> _getLibraryPath(String type) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case 'cómic':
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
            items: const [
              DropdownMenuItem(
                value: 'book', // Valor real que se almacenará
                child: Text('Libro'), // Texto que se muestra
              ),
              DropdownMenuItem(value: 'comic', child: Text('Cómic')),
              DropdownMenuItem(value: 'audiobook', child: Text('Audiolibro')),
              DropdownMenuItem(value: 'other', child: Text('Otro')),
            ],
            onChanged:
                uploading
                    ? null
                    : (value) {
                      setState(() => selectedType = value!);
                    },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: uploading ? null : () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: uploading ? null : _uploadFile,
          child:
              uploading
                  ? const CustomLoader(size: 60.0, color: Colors.blue)
                  : const Text('Importar'),
        ),
      ],
    );
  }
}
