import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

void showComicDetailsDialog(BuildContext context, Comic comic) {
  final dateFormat = DateFormat('dd/MM/yyyy'); // Formato de fecha

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(comic.title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width:
              MediaQuery.of(context).size.width *
              0.3, // Ajusta el ancho del diálogo
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información básica
                _buildDetailRow('Escritor:', comic.writer ?? ''),
                _buildDetailRow(
                  'Publicación:',
                  dateFormat.format(comic.publicationDate ?? DateTime.now()),
                ),
                _buildDetailRow(
                  'Añadido:',
                  dateFormat.format(comic.creationDate),
                ),

                // Información adicional (si existe)
                if (comic.publisher != null)
                  _buildDetailRow('Editorial:', comic.publisher!),
                if (comic.language != null)
                  _buildDetailRow('Idioma:', comic.language!),
                if (comic.series != null)
                  _buildDetailRow(
                    'Serie:',
                    '${comic.series}${comic.seriesNumber != null ? ' #${comic.seriesNumber}' : ''}',
                  ),
                if (comic.tags != null)
                  _buildDetailRow('Etiquetas:', comic.tags!),
                if (comic.fileSize != null)
                  _buildDetailRow(
                    'Tamaño:',
                    '${(comic.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB',
                  ),

                // Descripción (si existe)
                if (comic.description != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Descripción:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(comic.description!, textAlign: TextAlign.justify),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context),
          ),
          if (comic.filePath != null)
            TextButton(
              child: const Text('Abrir'),
              onPressed: () {
                Navigator.pop(context);
                // Aquí la lógica para abrir el libro
                // Ejemplo: _openBook(comic.filePath!);
              },
            ),
        ],
      );
    },
  );
}

// Widget auxiliar para mostrar filas de información
Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}
