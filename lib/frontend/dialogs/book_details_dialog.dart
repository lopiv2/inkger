import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

void showBookDetailsDialog(BuildContext context, Book book) {
  final dateFormat = DateFormat('dd/MM/yyyy'); // Formato de fecha

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(book.title, style: TextStyle(fontWeight: FontWeight.bold)),
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
                _buildDetailRow('Autor:', book.author),
                _buildDetailRow(
                  'Publicación:',
                  dateFormat.format(book.publicationDate),
                ),
                _buildDetailRow(
                  'Añadido:',
                  dateFormat.format(book.creationDate),
                ),

                // Información adicional (si existe)
                if (book.publisher != null)
                  _buildDetailRow('Editorial:', book.publisher!),
                if (book.language != null)
                  _buildDetailRow('Idioma:', book.language!),
                if (book.series != null)
                  _buildDetailRow(
                    'Serie:',
                    '${book.series}${book.seriesNumber != null ? ' #${book.seriesNumber}' : ''}',
                  ),
                if (book.tags != null)
                  _buildDetailRow('Etiquetas:', book.tags!),
                if (book.fileSize != null)
                  _buildDetailRow(
                    'Tamaño:',
                    '${(book.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB',
                  ),

                // Descripción (si existe)
                if (book.description != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Descripción:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(book.description!, textAlign: TextAlign.justify),
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
          if (book.filePath != null)
            TextButton(
              child: const Text('Abrir'),
              onPressed: () {
                Navigator.pop(context);
                // Aquí la lógica para abrir el libro
                // Ejemplo: _openBook(book.filePath!);
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
