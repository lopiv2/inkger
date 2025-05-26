import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/utils/functions.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';

class CompareBookDialog extends StatefulWidget {
  final Map<String, String> currentBook;
  final Map<String, dynamic> newBookData;

  const CompareBookDialog({
    super.key,
    required this.currentBook,
    required this.newBookData,
  });

  @override
  State<CompareBookDialog> createState() => _SelectableCompareBookDialogState();
}

class _SelectableCompareBookDialogState extends State<CompareBookDialog> {
  late Map<String, dynamic> selectedValues;

  @override
  void initState() {
    super.initState();
    // Inicializar con los valores actuales (Strings)
    selectedValues = {
      'title': 'actual::${widget.currentBook['title'] ?? ''}',
      'author': 'actual::${widget.currentBook['author'] ?? ''}',
      'publisher': 'actual::${widget.currentBook['publisher'] ?? ''}',
      'publicationDate':
          'actual::${widget.currentBook['publicationDate'] ?? ''}',
      'language': 'actual::${widget.currentBook['language'] ?? ''}',
      'description': 'actual::${widget.currentBook['description'] ?? ''}',
      'origin': widget.newBookData['origin'] ?? '',
      'cover': 'actual::${widget.currentBook['coverPath'] ?? ''}',
    };
  }

  Widget buildFieldSelector({
    required String label,
    required String currentValue,
    required String newValue,
    required String keyName,
  }) {
    final actualValue = 'actual::$currentValue';
    final nuevoValue = 'nuevo::$newValue';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text("Actual: $currentValue"),
                value: actualValue,
                groupValue: selectedValues[keyName],
                onChanged: (value) {
                  setState(() => selectedValues[keyName] = value);
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text("Nuevo: $newValue"),
                value: nuevoValue,
                groupValue: selectedValues[keyName],
                onChanged: (value) {
                  setState(() => selectedValues[keyName] = value);
                },
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget buildCoverPreview() {
    final actualCover = widget.currentBook['coverPath'] ?? '';
    final newCover = widget.newBookData['cover'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portada',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Actual'),
                  actualCover.isNotEmpty
                      ? buildCoverImage(actualCover, width: 100)
                      : const Icon(Icons.broken_image, size: 100),
                  Radio<String>(
                    value: 'actual::$actualCover',
                    groupValue: selectedValues['cover'],
                    onChanged: (value) {
                      setState(() => selectedValues['cover'] = value);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('Nueva'),
                  newCover.isNotEmpty
                      ? Image.network(newCover, height: 150, fit: BoxFit.cover)
                      : const Icon(Icons.broken_image, size: 100),
                  Radio<String>(
                    value: 'nuevo::$newCover',
                    groupValue: selectedValues['cover'],
                    onChanged: (value) {
                      setState(() => selectedValues['cover'] = value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Selecciona los metadatos a guardar"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            buildCoverPreview(),
            buildFieldSelector(
              label: "Título",
              currentValue: widget.currentBook['title'] ?? '',
              newValue: widget.newBookData['title'] ?? '',
              keyName: 'title',
            ),
            buildFieldSelector(
              label: "Autor",
              currentValue: widget.currentBook['author'] ?? '',
              newValue: widget.newBookData['author'] ?? '',
              keyName: 'author',
            ),
            buildFieldSelector(
              label: "Editorial",
              currentValue: widget.currentBook['publisher'] ?? '',
              newValue: widget.newBookData['publisher'] ?? '',
              keyName: 'publisher',
            ),
            buildFieldSelector(
              label: "Fecha",
              currentValue: widget.currentBook['publicationDate'] ?? '',
              newValue: (widget.newBookData['publicationDate'] ?? '')
                  .toString(),
              keyName: 'publicationDate',
            ),
            buildFieldSelector(
              label: "Idioma",
              currentValue: widget.currentBook['language'] ?? '',
              newValue: widget.newBookData['language'] ?? '',
              keyName: 'language',
            ),
            buildFieldSelector(
              label: "Descripción",
              currentValue: widget.currentBook['description'] ?? '',
              newValue: widget.newBookData['description'] ?? '',
              keyName: 'description',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () async {
            final cleanedData = _getCleanedMetadata();
            final publicationDate = parsePublicationDate(
              cleanedData['publicationDate'],
            );
            final updatedBook = Book(
              id: int.tryParse(widget.currentBook['id'] ?? '0') ?? 0,
              title: cleanedData['title'] ?? '',
              description: cleanedData['description']?.isNotEmpty == true
                  ? cleanedData['description']
                  : null,
              filePath: widget.currentBook['filePath'] ?? '',
              fileSize:
                  int.tryParse(widget.currentBook['fileSize'] ?? '0') ?? 0,
              identifiers: widget.currentBook['identifiers'] ?? null,
              tags: widget.currentBook['tags'],
              series: widget.currentBook['series'],
              seriesNumber:
                  int.tryParse(widget.currentBook['seriesNumber'] ?? '0') ?? 0,
              pages: int.tryParse(widget.currentBook['pages'] ?? '0') ?? 0,
              language: cleanedData['language']?.isNotEmpty == true
                  ? cleanedData['language']
                  : null,
              publisher: cleanedData['publisher']?.isNotEmpty == true
                  ? cleanedData['publisher']
                  : null,
              author: cleanedData['author'] ?? '',
              coverPath:
                  cleanedData['cover'] ?? widget.currentBook['coverPath'] ?? '',
              publicationDate: publicationDate!,
              creationDate: cleanedData['creationDate'] != null
                  ? DateTime.parse(cleanedData['creationDate']!)
                  : DateTime.now(),
            );

            try {
              //print(updatedBook.toJson());
              await BookServices.updateBook(updatedBook);
              if (context.mounted) Navigator.pop(context, true); // indica éxito
              CustomSnackBar.show(
                context,
                AppLocalizations.of(context)!.updateMetadataSuccess,
                Colors.green,
                duration: Duration(seconds: 4),
              );
            } catch (e) {
              // Muestra error si falla
              if (context.mounted) {
                CustomSnackBar.show(
                  context,
                  AppLocalizations.of(context)!.updateMetadataError,
                  Colors.red,
                  duration: Duration(seconds: 4),
                );
              }
            }
          },
          child: Text(AppLocalizations.of(context)!.updateMetadata),
        ),
      ],
    );
  }

  Map<String, String> _getCleanedMetadata() {
    final cleaned = <String, String>{};

    for (var key in selectedValues.keys) {
      final value = selectedValues[key];
      if (value is String && value.contains('::')) {
        cleaned[key] = value.split('::')[1];
      } else if (value is String) {
        cleaned[key] = value;
      }
    }

    return cleaned;
  }
}
