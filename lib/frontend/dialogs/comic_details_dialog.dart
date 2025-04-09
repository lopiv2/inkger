import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

List<String> parseCommaSeparatedList(dynamic data) {
  if (data == null) return [];

  if (data is List) {
    return data
        .expand((item) => item.toString().split(','))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  if (data is String) {
    return data
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  return [];
}

void showComicDetailsDialog(BuildContext context, Comic comic) {
  final dateFormat = DateFormat('dd/MM/yyyy'); // Formato de fecha

  // Controladores para campos editables
  final TextEditingController titleController = TextEditingController(
    text: comic.title,
  );
  final TextEditingController descriptionController = TextEditingController(
    text: comic.description,
  );
  final TextEditingController tagsController = TextEditingController(
    text: comic.tags,
  );
  final TextEditingController seriesController = TextEditingController(
    text: comic.series,
  );
  final TextEditingController languageController = TextEditingController(
    text: comic.language,
  );
  final TextEditingController publisherController = TextEditingController(
    text: comic.publisher,
  );
  final TextEditingController writerController = TextEditingController(
    text: comic.writer,
  );
  final TextEditingController pencillerController = TextEditingController(
    text: comic.penciller,
  );
  final TextEditingController lettererController = TextEditingController(
    text: comic.letterer,
  );
  final TextEditingController inkerController = TextEditingController(
    text: comic.inker,
  );
  final TextEditingController coloristController = TextEditingController(
    text: comic.colorist,
  );
  final TextEditingController coverArtistController = TextEditingController(
    text: comic.coverArtist,
  );
  final TextEditingController editorController = TextEditingController(
    text: comic.editor,
  );
  final TextEditingController storyArcController = TextEditingController(
    text: comic.storyArc,
  );
  final TextEditingController alternateSeriesController = TextEditingController(
    text: comic.alternateSeries,
  );

  // Variables para manejar los chips de listas
  List<String> tagsList = comic.tags?.split(',') ?? [];
  List<String> charactersList = comic.characters?.split(',') ?? [];
  List<String> teamsList = parseCommaSeparatedList(comic.teams);
  List<String> locationsList = parseCommaSeparatedList(comic.locations);
  List<String> storyArcList = comic.storyArc?.split(',') ?? [];
  List<String> alternateSeriesList = comic.alternateSeries?.split(',') ?? [];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(comic.title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width:
              MediaQuery.of(context).size.width *
              0.6, // Ajusta el ancho del diálogo
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información básica (campos editables)
                _buildEditableField('Título:', titleController),
                _buildEditableField(
                  'Descripción:',
                  descriptionController,
                  maxLines: 3,
                ),
                _buildEditableField('Escritor:', writerController),
                _buildEditableField('Dibujante:', pencillerController),
                _buildEditableField('Entintador:', inkerController),
                _buildEditableField('Colorista:', coloristController),
                _buildEditableField('Rotulista:', lettererController),
                _buildEditableField(
                  'Artista de portada:',
                  coverArtistController,
                ),
                _buildEditableField('Editor:', editorController),
                _buildEditableField('Editorial:', publisherController),
                _buildEditableField('Idioma:', languageController),
                _buildEditableField('Serie:', seriesController),

                // Campos de listas (tags, personajes, equipos, etc.)
                _buildChipsField('Etiquetas:', tagsList, tagsController),
                _buildChipsField('Personajes:', charactersList, null),
                _buildChipsField('Equipos:', teamsList, null),
                _buildChipsField('Lugares:', locationsList, null),
                _buildChipsField('Historia del arco:', storyArcList, null),
                _buildChipsField(
                  'Series alternativas:',
                  alternateSeriesList,
                  null,
                ),

                // Información adicional (si existe)
                if (comic.fileSize != null)
                  _buildDetailRow(
                    'Tamaño:',
                    '${(comic.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB',
                  ),
                if (comic.publicationDate != null)
                  _buildDetailRow(
                    'Publicación:',
                    dateFormat.format(comic.publicationDate ?? DateTime.now()),
                  ),
                _buildDetailRow(
                  'Añadido:',
                  dateFormat.format(comic.creationDate),
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
              // Guardar cambios aquí
              // Crea el comic con los nuevos datos editados
              Comic updatedComic = Comic(
                id: comic.id,
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
                language:
                    languageController.text.isNotEmpty
                        ? languageController.text
                        : null,
                publisher:
                    publisherController.text.isNotEmpty
                        ? publisherController.text
                        : null,
                writer:
                    writerController.text.isNotEmpty
                        ? writerController.text
                        : null,
                penciller:
                    pencillerController.text.isNotEmpty
                        ? pencillerController.text
                        : null,
                inker:
                    inkerController.text.isNotEmpty
                        ? inkerController.text
                        : null,
                colorist:
                    coloristController.text.isNotEmpty
                        ? coloristController.text
                        : null,
                letterer:
                    lettererController.text.isNotEmpty
                        ? lettererController.text
                        : null,
                coverArtist:
                    coverArtistController.text.isNotEmpty
                        ? coverArtistController.text
                        : null,
                editor:
                    editorController.text.isNotEmpty
                        ? editorController.text
                        : null,
                characters: charactersList.join(','),
                teams: teamsList.join(','),
                locations: locationsList.join(','),
                storyArc:
                    storyArcList.isNotEmpty ? storyArcList.join(',') : null,
                alternateSeries:
                    alternateSeriesList.isNotEmpty
                        ? alternateSeriesList.join(',')
                        : null,
                fileSize: comic.fileSize,
                filePath: comic.filePath,
                coverPath: comic.coverPath,
                publicationDate: comic.publicationDate,
                creationDate: comic.creationDate,
                // Otros campos adicionales
              );
              await ComicServices.updateComic(updatedComic);
              CustomSnackBar.show(
                context,
                AppLocalizations.of(context)!.metadataUpdated,
                Colors.green,
                duration: Duration(seconds: 4),
              );
              Navigator.pop(context); // Cerrar el diálogo
            },
          ),
        ],
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
Widget _buildChipsField(
  String label,
  List<String> values,
  TextEditingController? controller,
) {
  TextEditingController tempController = controller ?? TextEditingController();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Container(
              width: 100,
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Chips
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    values.map((value) {
                      return Chip(
                        label: Text(value),
                        onDeleted: () {
                          values.remove(value);
                          (controller == null)
                              ? tempController.text = values.join(',')
                              : controller!.text = values.join(',');
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
          decoration: const InputDecoration(
            labelText: 'Añadir nuevo',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (text) {
            final newTags =
                text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty && !values.contains(e))
                    .toList();

            if (newTags.isNotEmpty) {
              values.addAll(newTags);
              tempController.clear();
              (controller == null)
                  ? tempController.text = values.join(',')
                  : controller!.text = values.join(',');
            }
          },
        ),
      ],
    ),
  );
}

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
