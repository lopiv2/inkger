
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';

class FileImportDialog extends StatefulWidget {
  final String fileName;
  final String initType;
  final dynamic selectedFile;

  const FileImportDialog({
    required this.fileName,
    required this.initType,
    required this.selectedFile,
  });

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

  Future<void> _subirselectedFile() async {
    setState(() => uploading = true);

    try {
      final bytes = await widget.selectedFile.readAsBytes();
      final fileName = widget.fileName;

      final formData = FormData.fromMap({
        'selectedFile': MultipartFile.fromBytes(bytes, filename: fileName),
        'tipo': selectedType,
      });

      final response = await Dio().post(
        'http://tu-backend.com/api/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context,
          'Archivo importado correctamente',
          Colors.green,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      CustomSnackBar.show(
          context,
          'Error al importar',
          Colors.red,
        );
    } finally {
      setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Importando archivo seleccionado...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Archivo seleccionado: ${widget.fileName}'),
          SizedBox(height: 20),
          DropdownButton<String>(
            value: selectedType,
            items: ['Libro', 'Cómic', 'Audiolibro', 'Otro']
                .map((tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    ))
                .toList(),
            onChanged: uploading
                ? null
                : (value) => setState(() => selectedType = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: uploading ? null : () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: uploading ? null : _subirselectedFile,
          child: uploading
              ? CircularProgressIndicator()
              : Text('Importar'),
        ),
      ],
    );
  }
}