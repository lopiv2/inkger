import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComicMetadataSearchDialog extends StatefulWidget {
  final Comic comic;

  ComicMetadataSearchDialog({super.key, required this.comic});

  @override
  State<ComicMetadataSearchDialog> createState() =>
      _ComicMetadataSearchDialogState();
}

class _ComicMetadataSearchDialogState extends State<ComicMetadataSearchDialog> {
  int? _selectedIndex;
  List<Map<String, dynamic>> _comics =
      []; // Lista para almacenar los cómics obtenidos
  int _currentPage = 0; // Nueva variable de estado
  int _rowsPerPage = 5; // Nueva variable de estado

  @override
  Widget build(BuildContext context) {
    final selectedComic =
        (_selectedIndex != null && _selectedIndex! < _comics.length)
            ? _comics[_selectedIndex!]
            : null;
    //print(selectedComic?['image']);
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Título estilo barra superior
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.blueGrey,
              child: Text(
                'Buscando metadatos...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            // Chip ComicVine
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text('ComicVine'),
                backgroundColor: Colors.blueAccent,
              ),
            ),
            // Contenido dividido: tabla + imagen
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      // Usamos FutureBuilder para obtener los datos
                      future: findComicMetadata(widget.comic),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text('No se encontraron resultados.'),
                          );
                        } else {
                          _comics =
                              snapshot
                                  .data!; // Almacenamos los cómics obtenidos

                          return PaginatedDataTable(
                            key: PageStorageKey<String>('comicMetadataTable'),
                            header: Text('Resultados'),
                            columns: [
                              DataColumn(label: Text('Series')),
                              DataColumn(label: Text('Year')),
                              DataColumn(label: Text('Issues')),
                              DataColumn(label: Text('Publisher')),
                            ],
                            onPageChanged: (pageIndex) {
                              // Callback al cambiar de página
                              setState(() {
                                _currentPage = pageIndex;
                              });
                            },
                            onRowsPerPageChanged: (value) {
                              // Callback al cambiar filas por página
                              setState(() {
                                _rowsPerPage = value!;
                                _currentPage =
                                    0; // Reinicia a la primera página
                              });
                            },
                            availableRowsPerPage: [5, 10, 20], // Lista de opciones permitidas
                            initialFirstRowIndex: _currentPage,
                            source: ComicDataSource(
                              comics: _comics,
                              onRowSelected: (index) {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                            ),
                            rowsPerPage: 5,
                            columnSpacing: 20,
                            horizontalMargin: 10,
                            showCheckboxColumn: false,
                          );
                        }
                      },
                    ),
                  ),
                  VerticalDivider(),
                  // Imagen dinámica
                  Expanded(
                    flex: 2,
                    child:
                        selectedComic != null
                            ? Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    selectedComic['series']!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(177),
                                          blurRadius: 10, // Difuminado
                                          spreadRadius: 2, // Extensión
                                          offset: Offset(3, 3),
                                        ),
                                      ],
                                    ),
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                          0.4, // Altura máxima
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                          0.3, // Ancho máximo
                                    ),
                                    child: AspectRatio(
                                      aspectRatio:
                                          2 / 3, // Proporción típica de cómics
                                      child: FutureBuilder<Uint8List>(
                                        future: _getProxyImageBytes(
                                          selectedComic!['image']['small_url'],
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Image.memory(
                                              snapshot.data!,
                                              fit:
                                                  BoxFit
                                                      .contain, // Ajusta manteniendo proporción
                                            );
                                          } else if (snapshot.hasError) {
                                            return Icon(Icons.error);
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Center(child: Text('Selecciona un resultado')),
                  ),
                ],
              ),
            ),
            // Botón de búsqueda
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  findComicMetadata(widget.comic);
                },
                child: Text('Buscar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _getProxyImageBytes(String originalUrl) async {
    try {
      final response = await ApiService.dio.get(
        "/api/proxy",
        queryParameters: {"url": originalUrl},
        options: Options(
          responseType: ResponseType.bytes, // Recibir los bytes directamente
        ),
      );
      return response.data; // Devuelve los bytes de la imagen
    } catch (e) {
      print("Error al obtener imagen: $e");
      throw Exception("No se pudo cargar la imagen");
    }
  }

  Future<List<Map<String, dynamic>>> findComicMetadata(Comic comic) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    if (userId == null) {
      throw Exception('No se encontró el ID del usuario');
    }

    final searchResults = await ComicServices.getComicMetadata(
      userId,
      comic.title,
    );

    // Aquí procesas los resultados de la API de ComicVine
    List<Map<String, dynamic>> comics =
        searchResults.map((result) {
          return {
            'series': result['name'] ?? 'Desconocido',
            'year': result['year'] ?? 'N/A',
            'issues': result['count_of_issues']?.toString() ?? '0',
            'publisher': result['publisher']?['name'] ?? 'Desconocido',
            'image': result['image'] ?? '',
          };
        }).toList();

    return comics;
  }
}

class ComicDataSource extends DataTableSource {
  final List<Map<String, dynamic>> comics;
  final void Function(int) onRowSelected;

  ComicDataSource({required this.comics, required this.onRowSelected});

  @override
  DataRow getRow(int index) {
    final comic = comics[index];
    return DataRow(
      cells: [
        DataCell(Text(comic['series']!)),
        DataCell(Text(comic['year']!)),
        DataCell(Text(comic['issues']!)),
        DataCell(Text(comic['publisher']!)),
      ],
      onSelectChanged: (_) {
        onRowSelected(index);
      },
    );
  }

  @override
  int get rowCount => comics.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  @override
  bool get hasMoreRows => false;
}
