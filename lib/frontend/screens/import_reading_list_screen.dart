import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/models/reading_list.dart';
import 'package:inkger/frontend/dialogs/selection_dialog.dart';
import 'package:inkger/frontend/models/reading_list_item.dart';
import '../services/reading_list_services.dart';

class ImportReadingListScreen extends StatefulWidget {
  const ImportReadingListScreen({Key? key}) : super(key: key);

  @override
  State<ImportReadingListScreen> createState() =>
      _ImportReadingListScreenState();
}

class _ImportReadingListScreenState extends State<ImportReadingListScreen> {
  PlatformFile? selectedFile;
  List<Map<String, dynamic>> importedItems = [];
  late TextEditingController listTitleController; // Usar late para inicializar después
  Map<int, String> selectedSeries = {};
  Map<int, String> selectedTitle = {};
  Map<int, String> selectedId = {};
  Map<int, String> selectedType = {};

  _ImportReadingListScreenState() {
    listTitleController = TextEditingController(); // Inicializar en el constructor
  }

  @override
  void dispose() {
    listTitleController.dispose(); // Liberar recursos del controlador
    super.dispose();
  }

  Future<void> _importFile(PlatformFile file) async {
    try {
      final ReadingList readingList =
          await ReadingListServices.importReadingList(file);
      setState(() {
        listTitleController.text = readingList.title; // Establecer el título
        importedItems = readingList.items
            .asMap()
            .entries
            .map(
              (entry) => {
                'index': entry.key + 1,
                'series': entry.value.series,
                'number': entry.value.number,
                'year': entry.value.year,
                'title': '',
              },
            )
            .toList();
      });
    } catch (e) {
      print('Excepción al importar el archivo: $e');
    }
  }

  void _showSelectionDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SelectionDialog(
          title:
              importedItems[index]['series'] +
                  " #" +
                  importedItems[index]['number'].toString() ??
              'Sin título',
          onSelected: (selectedSeriesName) {
            setState(() {
              selectedSeries[index] =
                  '${selectedSeriesName['series']} #${selectedSeriesName['seriesNumber']}'; // Asegurar que sea un String
              selectedTitle[index] = '${selectedSeriesName['title']}';
              selectedId[index] = '${selectedSeriesName['id']}';
              selectedType[index] = '${selectedSeriesName['type']}';
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Reading List')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Import your reading list from a file:',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['cbl'],
                            );
                        if (result != null) {
                          setState(() {
                            selectedFile = result.files.single;
                          });
                          print('Archivo seleccionado: ${selectedFile!.name}');
                        } else {
                          print('Selección de archivo cancelada');
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choose File'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedFile != null) {
                          _importFile(selectedFile!);
                        } else {
                          print('No se ha seleccionado ningún archivo');
                        }
                      },
                      child: const Text('Import File'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Supported formats: .cbl',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    if (importedItems.isNotEmpty) ...[
                      if (listTitleController.text.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: listTitleController,
                                decoration: const InputDecoration(
                                  labelText: 'Lista importada',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                if (listTitleController.text.isNotEmpty &&
                                    selectedSeries.isNotEmpty) {
                                  final readingList = ReadingList(
                                    title: listTitleController.text, // Usar el título editado
                                    missingTitles:
                                        importedItems.length - selectedSeries.length,
                                    items: selectedSeries.entries.map((entry) {
                                      final index = entry.key;
                                      final seriesData = entry.value.split(' #');
                                      return ReadingListItem(
                                        id: selectedId[index] ?? '', // Usar el id seleccionado
                                        type: selectedType[index] ?? 'comic', // Usar el tipo seleccionado
                                        series: seriesData[0], // Serie seleccionada
                                        number: seriesData.length > 1 ? seriesData[1] : '', // Número seleccionado
                                        volume: '', // Asignar vacío si no está disponible
                                        year: '',
                                        orderNumber: index,
                                        title: selectedTitle[index] ?? '', // Asignar vacío si no está disponible
                                      );
                                    }).toList(),
                                  );

                                  try {
                                    await ReadingListServices.sendReadingList(
                                      readingList.toJson(),
                                    );
                                    context.pop();
                                    print('ReadingList enviada exitosamente.');
                                  } catch (e) {
                                    print('Error al enviar la ReadingList: $e');
                                  }
                                } else {
                                  print(
                                    'No hay datos seleccionados para crear la lista.',
                                  );
                                }
                              },
                              child: const Text('Crear'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      const Text(
                        'Imported Items:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FixedColumnWidth(40), // Para la columna #
                          1: FlexColumnWidth(), // Para la columna serie
                          2: FixedColumnWidth(50), // Para la columna nº
                          3: FlexColumnWidth(), // Para la columna serie donde elegiré el libro
                          4: FlexColumnWidth(), // Para la columna título
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: Colors.grey),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('#', textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Serie',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Nº', textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Ejemplar de la biblioteca',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Título',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          ...importedItems.map(
                            (item) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${item['index']}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${item['series']} (${item['year']})',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${item['number']}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  (selectedSeries[item['index'] -
                                                              1] ??
                                                          '')
                                                      .isEmpty
                                                  ? Colors
                                                        .red // Borde rojo si está vacío
                                                  : Colors
                                                        .transparent, // Sin borde si tiene valor
                                              width: 2.0,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4.0,
                                            ),
                                          ),
                                          child: TextField(
                                            readOnly: true,
                                            controller: TextEditingController(
                                              text:
                                                  selectedSeries[item['index'] -
                                                      1] ??
                                                  '', // Acceder correctamente al índice
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder
                                                  .none, // Sin recuadro
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          _showSelectionDialog(
                                            item['index'] - 1,
                                          ); // Pasar el índice del elemento
                                        },
                                        child: const Text('Seleccionar'),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    selectedTitle[item['index'] - 1] ??
                                        '', // Mostrar el título devuelto por el diálogo
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
