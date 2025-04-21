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
  List<Map<String, dynamic>> _comics = [];
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedComic =
        (_selectedIndex != null && _selectedIndex! < _comics.length)
            ? _comics[_selectedIndex!]
            : null;

    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.95,
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
            // Barra de búsqueda y botón
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar en ComicVine...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: _isSearching
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Buscar'),
                  ),
                ],
              ),
            ),
            // Contenido dividido: tabla + imagen
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _comics.isEmpty
                        ? Center(child: Text('Ingresa un término de búsqueda'))
                        : PaginatedDataTable(
                            key: PageStorageKey<String>('comicMetadataTable'),
                            header: Text('Resultados'),
                            columns: [
                              DataColumn(label: Text('Series')),
                              DataColumn(label: Text('Year')),
                              DataColumn(label: Text('Issues')),
                              DataColumn(label: Text('Publisher')),
                            ],
                            onPageChanged: (pageIndex) {
                              setState(() {
                                _currentPage = pageIndex;
                              });
                            },
                            onRowsPerPageChanged: (value) {
                              setState(() {
                                _rowsPerPage = value!;
                                _currentPage = 0;
                              });
                            },
                            availableRowsPerPage: [5, 10, 20],
                            initialFirstRowIndex: _currentPage,
                            source: ComicDataSource(
                              comics: _comics,
                              onRowSelected: (index) {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                            ),
                            rowsPerPage: _rowsPerPage,
                            columnSpacing: 20,
                            horizontalMargin: 10,
                            showCheckboxColumn: false,
                          ),
                  ),
                  VerticalDivider(),
                  // Imagen dinámica
                  Expanded(
                    flex: 2,
                    child: selectedComic != null
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
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: Offset(3, 3),
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height * 0.55,
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.45,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 2 / 3,
                                    child: FutureBuilder<Uint8List>(
                                      future: _getProxyImageBytes(
                                        selectedComic!['image']['small_url'],
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.contain,
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
            // Botón de cerrar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
      _comics = []; // Limpiar resultados anteriores
    });

    try {
      final results = await findComicMetadata(widget.comic.copyWith(
        title: _searchController.text,
      ));

      setState(() {
        _comics = results;
        _selectedIndex = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<Uint8List> _getProxyImageBytes(String originalUrl) async {
    try {
      final response = await ApiService.dio.get(
        "/api/proxy",
        queryParameters: {"url": originalUrl},
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      return response.data;
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

    return searchResults.map((result) {
      return {
        'series': result['name'] ?? 'Desconocido',
        'year': result['year'] ?? 'N/A',
        'issues': result['count_of_issues']?.toString() ?? '0',
        'publisher': result['publisher']?['name'] ?? 'Desconocido',
        'image': result['image'] ?? '',
      };
    }).toList();
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