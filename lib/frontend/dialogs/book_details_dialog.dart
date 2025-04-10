import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/widgets/chips_field.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para formatear fechas

void showBookDetailsDialog(BuildContext context, Book book) async {
  final dateFormat = DateFormat('dd/MM/yyyy'); // Formato de fecha
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getInt('id');

  final provider = Provider.of<BooksProvider>(context, listen: false);

  // Controladores para campos editables
  final TextEditingController titleController = TextEditingController(
    text: book.title,
  );
  final TextEditingController descriptionController = TextEditingController(
    text: book.description,
  );
  final TextEditingController tagsController = TextEditingController(
    text: book.tags,
  );
  final TextEditingController seriesController = TextEditingController(
    text: book.series,
  );
  final TextEditingController seriesNumberController = TextEditingController(
    text: book.seriesNumber.toString(),
  );
  final TextEditingController languageController = TextEditingController(
    text: book.language,
  );
  final TextEditingController publisherController = TextEditingController(
    text: book.publisher,
  );
  final TextEditingController authorController = TextEditingController(
    text: book.author,
  );

  // Variables para manejar los chips de listas
  List<String> tagsList = book.tags?.split(',') ?? [];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              book.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildEditableField('Título:', titleController),
                    _buildEditableField(
                      'Descripción:',
                      descriptionController,
                      maxLines: 3,
                    ),
                    _buildEditableField('Autor:', authorController),
                    _buildEditableField('Editorial:', publisherController),
                    _buildEditableField('Idioma:', languageController),
                    _buildEditableField('Serie:', seriesController),
                    _buildEditableField('Nº en serie:', seriesNumberController),

                    ChipsField(
                      label: 'Etiquetas:',
                      values: tagsList,
                      //controller: tagsController,
                      onChanged: (newValues) {
                        setState(() {
                          tagsList = newValues;
                        });
                      },
                    ),

                    if (book.fileSize != null)
                      _buildDetailRow(
                        'Tamaño:',
                        '${(book.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB',
                      ),
                    _buildDetailRow(
                      'Publicación:',
                      dateFormat.format(book.publicationDate),
                    ),
                    _buildDetailRow(
                      'Añadido:',
                      dateFormat.format(book.creationDate),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Guardar'),
                onPressed: () async {
                  Book updatedBook = Book(
                    id: book.id,
                    title: titleController.text,
                    description:
                        descriptionController.text.isNotEmpty
                            ? descriptionController.text
                            : null,
                    tags: tagsList.join(','),
                    series:
                        seriesController.text.isNotEmpty
                            ? seriesController.text
                            : null,
                    seriesNumber:
                        seriesNumberController.text.isNotEmpty
                            ? int.tryParse(seriesNumberController.text)
                            : 0,
                    pages: book.pages,
                    language:
                        languageController.text.isNotEmpty
                            ? languageController.text
                            : null,
                    publisher:
                        publisherController.text.isNotEmpty
                            ? publisherController.text
                            : null,
                    author: authorController.text,
                    fileSize: book.fileSize,
                    filePath: book.filePath,
                    coverPath: book.coverPath,
                    publicationDate: book.publicationDate,
                    creationDate: book.creationDate,
                  );

                  await BookServices.updateBook(updatedBook);
                  await provider.loadBooks(id ?? 0);

                  CustomSnackBar.show(
                    context,
                    AppLocalizations.of(context)!.metadataUpdated,
                    Colors.green,
                    duration: Duration(seconds: 4),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    },
  );
}

// Widget auxiliar para campos editables
Widget _buildEditableField(
  String label,
  TextEditingController controller, {
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    ),
  );
}

// Widget auxiliar para chips (listas de valores)

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
