import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inkger/frontend/models/book.dart';

void showBookDetailsDialog(BuildContext context, Book book) {
  final dateFormat = DateFormat('dd/MM/yyyy');

  // Controladores de texto
  final titleController = TextEditingController(text: book.title);
  final descriptionController = TextEditingController(text: book.description ?? '');
  final authorController = TextEditingController(text: book.author ?? '');
  final publisherController = TextEditingController(text: book.publisher ?? '');
  final languageController = TextEditingController(text: book.language ?? '');
  final seriesController = TextEditingController(text: book.series ?? '');
  final seriesNumberController = TextEditingController(text: book.seriesNumber?.toString() ?? '');
  final tagsController = TextEditingController(text: book.tags ?? '');

  final fileSizeController = TextEditingController(
      text: book.fileSize != null ? (book.fileSize! / 1024 / 1024).toStringAsFixed(2) : '');

  final publicationDateController =
      TextEditingController(text: book.publicationDate != null ? dateFormat.format(book.publicationDate!) : '');

  // Conversión para chips
  List<String> _toList(dynamic source) {
    if (source is List) {
      return source.map((e) => e.toString()).toList();
    } else if (source is String) {
      return source
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  final tags = _toList(book.tags);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Editar libro'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Título', titleController),
                _buildTextField('Autor', authorController),
                _buildTextField('Editorial', publisherController),
                _buildTextField('Idioma', languageController),
                _buildTextField('Serie', seriesController),
                _buildTextField('Número en serie', seriesNumberController, inputType: TextInputType.number),
                _buildTextField('Tamaño (MB)', fileSizeController, inputType: TextInputType.number),
                _buildTextField('Fecha de publicación', publicationDateController),
                _buildTextField('Descripción', descriptionController, maxLines: 3),
                const SizedBox(height: 12),
                _buildChipsField('Etiquetas:', tags, tagsController),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Guardar'),
            onPressed: () {
              // Aquí puedes hacer la llamada a tu API para actualizar el libro
              // Ejemplo:
              // updateBook(book.id, {
              //   'title': titleController.text,
              //   'description': descriptionController.text,
              //   ...
              // });

              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

Widget _buildTextField(String label, TextEditingController controller,
    {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    ),
  );
}

Widget _buildChipsField(
  String label,
  List<String> values,
  TextEditingController controller,
) {
  final tempController = TextEditingController();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: values.map((value) {
                  return Chip(
                    label: Text(value),
                    onDeleted: () {
                      values.remove(value);
                      controller.text = values.join(',');
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: tempController,
          decoration: InputDecoration(
            labelText: 'Añadir nuevo',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (text) {
            if (text.trim().isNotEmpty) {
              values.add(text.trim());
              tempController.clear();
              controller.text = values.join(',');
            }
          },
        ),
      ],
    ),
  );
}
