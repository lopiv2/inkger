import 'package:flutter/material.dart';

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
      'title': widget.currentBook['title'] ?? '',
      'author': widget.currentBook['author'] ?? '',
      'publisher': widget.currentBook['publisher'] ?? '',
      'publicationDate': widget.currentBook['publicationDate'] ?? '',
      'language': widget.currentBook['language'] ?? '',
      'description': widget.currentBook['description'] ?? '',
      'origin': widget.newBookData['origin'] ?? '',
      'cover': widget.newBookData['cover'],
    };
  }

  Widget buildFieldSelector({
    required String label,
    required String currentValue,
    required String newValue,
    required String keyName,
  }) {
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
                value: currentValue,
                groupValue: selectedValues[keyName],
                onChanged: (value) {
                  setState(() => selectedValues[keyName] = value);
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text("Nuevo: $newValue"),
                value: newValue,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Selecciona los metadatos a guardar"),
      content: SingleChildScrollView(
        child: Column(
          children: [
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
              newValue: (widget.newBookData['publicationDate'] ?? '').toString(),
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
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedValues),
          child: const Text("Guardar selección"),
        ),
      ],
    );
  }
}
