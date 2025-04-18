import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/comic_services.dart';

class ConvertOptionsDialog extends StatelessWidget {
  final int comicId;

  const ConvertOptionsDialog({Key? key, required this.comicId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Convertir archivo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ComicServices.convertToCBR(comicId);
            },
            icon: const Icon(Icons.file_present),
            label: const Text('Convertir a CBR'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ComicServices.convertToCBZ(comicId);
            },
            icon: const Icon(Icons.folder_zip),
            label: const Text('Convertir a CBZ'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
