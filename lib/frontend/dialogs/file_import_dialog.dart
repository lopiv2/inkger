import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/utils/constants.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';

class FileImportDialog extends StatefulWidget {
  final PlatformFile file;
  final String initType;

  const FileImportDialog({
    required this.file,
    required this.initType,
    Key? key, // Añade Key como parámetro opcional
  }) : super(key: key);

  @override
  _FileImportDialogState createState() => _FileImportDialogState();
}

class _FileImportDialogState extends State<FileImportDialog> {
  late String selectedType;
  bool uploading = false;
  late final Dio _dio; // Usa una instancia local en lugar de la global

  @override
  void initState() {
    super.initState();
    selectedType = widget.initType;
    _dio = Dio(ApiService.dio.options); // Clona la configuración
  }

  Future<void> _uploadFile() async {
    setState(() => uploading = true);
    if (widget.file.bytes == null) {
      _showError('El archivo está vacío');
      return;
    }

    try {
      final formData = FormData.fromMap({
        'selectedFile': MultipartFile.fromBytes(
          widget.file.bytes!,
          filename: widget.file.name,
        ),
        'tipo': selectedType.toLowerCase(),
      });

      final response = await ApiService.uploadFile(
        path: '/api/upload',
        data: formData,
        context: context, // Optional context for auth
        onSendProgress: (sent, total) {
          debugPrint('Progreso: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );

      if (response.statusCode == 200) {
        _showSuccess(response.data['path']);
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      _showError('Error uploading file: ${e.toString()}');
    } finally {
      if (mounted) setState(() => uploading = false);
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

  @override
  void dispose() {
    _dio.close(); // Solo cierra la instancia local
    super.dispose();
  }
}
