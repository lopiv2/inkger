import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/file_import_dialog.dart';
import 'package:path/path.dart' as p;

class ImportFile extends StatefulWidget {
  const ImportFile({super.key});

  @override
  State<ImportFile> createState() => _ImportFileState();
}

class _ImportFileState extends State<ImportFile> {
  Future<void> _handleFileImport(List<PlatformFile> files) async {
    if (files.isEmpty) return;

    final file = files.first;
    final fileName = file.name;
    final fileType = _determineFileType(fileName);

    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => FileImportDialog(
              fileName: fileName,
              initType: fileType,
              selectedFile: file,
            ),
      );
    }
  }

  String _determineFileType(String fileName) {
    final extension = p.extension(fileName).toLowerCase();
    switch (extension) {
      case '.epub':
        return 'Libro';
      case '.cbz':
      case '.cbr':
        return 'Cómic';
      case '.mp3':
      case '.m4a':
        return 'Audiolibro';
      case '.pdf':
        return 'Documento PDF';
      default:
        return 'Otro archivo';
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['epub', 'cbz', 'cbr', 'mp3', 'm4a', 'pdf'],
    );

    if (result != null) {
      _handleFileImport(result.files);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file, size: 48),
            const SizedBox(height: 16),
            Text(
              'Haz clic para subir archivos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '(Formatos soportados: EPUB, CBZ, CBR, MP3, M4A, PDF)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
