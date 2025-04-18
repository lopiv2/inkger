import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/utils/book_filter_provider.dart';
import 'package:inkger/frontend/utils/book_list_item.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/functions.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/book_view_switcher.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/frontend/widgets/hover_card_book.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

enum ViewMode { simple, threeD, librarian }

class BooksGrid extends StatefulWidget {
  @override
  State<BooksGrid> createState() => _BooksGridState();
}

class _BooksGridState extends State<BooksGrid> {
  double _crossAxisCount = 5;
  final double _minCrossAxisCount = 5;
  final double _maxCrossAxisCount = 10;
  ViewMode _selectedViewMode = ViewMode.simple;
  final ValueNotifier<Color> _dominantColorNotifier = ValueNotifier<Color>(
    Colors.grey,
  ); // Color por defecto
  //late Future<Color> _dominantColorFuture;
  bool _colorCalculated = false;

  @override
  void dispose() {
    _dominantColorNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Usar WidgetsBinding para posponer la carga después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBooks();
    });
  }

  Future<void> _loadBooks() async {
    try {
      // Obtener provider con listen: false
      final provider = Provider.of<BooksProvider>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('id');

      // Cargar libros
      await provider.loadBooks(id ?? 0);

      // Obtener libros y filtros
      final books = Provider.of<BooksProvider>(context, listen: false).books;
      final filters = Provider.of<BookFilterProvider>(context, listen: false);

      // Autores únicos (con manejo de nulos)
      final authors =
          books
              .map((b) => b.author.trim()) // Manejo de author null
              .where((a) => a.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      filters.fillAuthors(authors);

      // Publishers únicos (con manejo de nulos)
      final publishers =
          books
              .map((b) => b.publisher?.trim() ?? '') // Manejo de publisher null
              .where((p) => p.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      filters.fillPublishers(publishers);
    } catch (e) {
      debugPrint('Error loading books: $e');
      // Opcional: mostrar snackbar con el error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar libros: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<BookFilterProvider>(context);
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    _crossAxisCount = prefs.preferences.defaultGridItemSize;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      filters.toggleFilterMenu();
                    },
                    icon: const Icon(Icons.filter_alt_outlined),
                    label: const Text('Filtrar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  BookViewSwitcher(),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.3),
                  Text("Modo:", style: TextStyle(fontSize: 14)),
                  Radio<ViewMode>(
                    value: ViewMode.simple,
                    groupValue: _selectedViewMode,
                    onChanged:
                        (value) => setState(() => _selectedViewMode = value!),
                  ),
                  Text(
                    "Simple",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Radio<ViewMode>(
                    value: ViewMode.threeD,
                    groupValue: _selectedViewMode,
                    onChanged:
                        (value) => setState(() => _selectedViewMode = value!),
                  ),
                  Text(
                    "3D",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Radio<ViewMode>(
                    value: ViewMode.librarian,
                    groupValue: _selectedViewMode,
                    onChanged:
                        (value) => setState(() => _selectedViewMode = value!),
                  ),
                  Text(
                    "Bibliotecario",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Slider(
              value: _crossAxisCount,
              min: _minCrossAxisCount,
              max: _maxCrossAxisCount,
              divisions: (_maxCrossAxisCount - _minCrossAxisCount).toInt(),
              label: _crossAxisCount.round().toString(),
              onChanged: (value) => setState(() => _crossAxisCount = value),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Consumer<BookFilterProvider>(
            builder: (context, filterProvider, child) {
              // Solo mostrar el Wrap si hay autores o publishers seleccionados
              if (filterProvider.isFilterMenuVisible) {
                return FiltersLayout(context);
              }

              if (filterProvider.selectedAuthors.isEmpty &&
                  filterProvider.selectedPublishers.isEmpty) {
                return SizedBox(); // No mostrar nada si no hay filtros activos
              }

              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0, // Espacio entre chips
                  runSpacing: 4.0, // Espacio entre filas de chips
                  children: [
                    // Mostrar chips de autores seleccionados
                    ...filterProvider.selectedAuthors.map((author) {
                      return Chip(
                        label: Text("Autor: $author"),
                        deleteIcon: Icon(Icons.clear),
                        onDeleted: () {
                          // Eliminar autor del provider
                          filterProvider.removeAuthor(author);
                        },
                      );
                    }),

                    // Mostrar chips de publishers seleccionados
                    ...filterProvider.selectedPublishers.map((publisher) {
                      return Chip(
                        label: Text("Editorial: $publisher"),
                        deleteIcon: Icon(Icons.clear),
                        onDeleted: () {
                          // Eliminar publisher del provider
                          filterProvider.removePublisher(publisher);
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Libros",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxHeight = constraints.maxHeight;
                double itemHeight =
                    CommonServices.calculateMainAxisExtent(
                      _crossAxisCount,
                    ).toDouble();

                // Si el itemHeight es mayor que el espacio disponible, limitarlo
                if (itemHeight * (_crossAxisCount / 2) > maxHeight) {
                  itemHeight = maxHeight / (_crossAxisCount / 5);
                }
                return Consumer<BooksProvider>(
                  builder: (context, booksProvider, child) {
                    final books = booksProvider.books;
                    // Filtrar libros según los filtros activos
                    final filteredBooks = _filterBooks(books);

                    if (books.isEmpty) {
                      return Center(child: Text("No hay libros disponibles"));
                    }
                    if (filters.isGridView) {
                      return GridView.builder(
                        padding: EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _crossAxisCount.round(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: CommonServices.calculateAspectRatio(
                            _crossAxisCount,
                          ),
                          mainAxisExtent: itemHeight,
                        ),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          final coverPath = book.coverPath;

                          switch (_selectedViewMode) {
                            case ViewMode.simple:
                              return _buildSimpleMode(context, book, coverPath);
                            case ViewMode.threeD:
                              return _build3DMode(
                                context,
                                book,
                                coverPath,
                                itemHeight,
                              );
                            case ViewMode.librarian:
                              return _buildLibrarianMode(book, coverPath);
                          }
                        },
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredBooks.length,
                        itemBuilder:
                            (context, index) =>
                                BookListItem(book: filteredBooks[index]),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget FiltersLayout(BuildContext context) {
    final filters = Provider.of<BookFilterProvider>(context);
    final hasActiveFilters =
        filters.selectedAuthors.isNotEmpty ||
        filters.selectedPublishers.isNotEmpty;

    return Visibility(
      visible: filters.isFilterMenuVisible,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila de filtros activos con chips
            if (hasActiveFilters) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Filtros activos:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // Chips de autores
                  ...filters.selectedAuthors.map((author) {
                    return Chip(
                      label: Text('Autor: $author'),
                      onDeleted: () {
                        filters.removeAuthor(author);
                      },
                    );
                  }),
                  // Chips de editoriales
                  ...filters.selectedPublishers.map((publisher) {
                    return Chip(
                      label: Text('Editorial: $publisher'),
                      onDeleted: () {
                        filters.removePublisher(publisher);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Filtros desplegables
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna de Autores
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Autor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        hint: const Text('Selecciona autores'),
                        items:
                            filters.availableAuthors.map((author) {
                              return DropdownMenuItem<String>(
                                value: author,
                                child: Text(author),
                              );
                            }).toList(),
                        onChanged: (selectedAuthor) {
                          if (selectedAuthor != null) {
                            filters.toggleAuthor(selectedAuthor);
                          }
                        },
                        value: null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 32),

                // Columna de Editoriales
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Editorial',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        hint: const Text('Selecciona editoriales'),
                        items:
                            filters.availablePublishers.map((publisher) {
                              return DropdownMenuItem<String>(
                                value: publisher,
                                child: Text(publisher),
                              );
                            }).toList(),
                        onChanged: (selectedPublisher) {
                          if (selectedPublisher != null) {
                            filters.togglePublisher(selectedPublisher);
                          }
                        },
                        value: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Función para filtrar los libros
  List<Book> _filterBooks(List<Book> books) {
    final filters = Provider.of<BookFilterProvider>(context, listen: false);

    return books.where((book) {
      final matchesAuthor =
          filters.selectedAuthors.isEmpty ||
          filters.selectedAuthors.contains(book.author.trim());

      final matchesPublisher =
          filters.selectedPublishers.isEmpty ||
          filters.selectedPublishers.contains(book.publisher?.trim() ?? '');

      return matchesAuthor && matchesPublisher;
    }).toList();
  }

  Widget _buildSimpleMode(BuildContext context, Book book, String? coverPath) {
    return Column(
      children: [
        HoverCardBook(
          book: book,
          onDelete: () => showDeleteConfirmationDialog(context, book),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: buildCoverImage(coverPath ?? ''),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                    child: LinearProgressIndicator(
                      value: book.readingProgress!['readingProgress'] / 100,
                      minHeight: 10,
                      backgroundColor: Colors.green[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            Text(
              book.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: CommonServices.calculateTextSize(_crossAxisCount),
              ),
            ),
            Text(
              book.author,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: CommonServices.calculateTextSize(_crossAxisCount),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _build3DMode(
    BuildContext context,
    Book book,
    String? coverPath,
    double itemHeight,
  ) {
    return Column(
      children: [
        Tilt(
          tiltConfig: TiltConfig(
            angle: 20, // Inclinación máxima
          ),
          childLayout: ChildLayout(
            behind: [
              Positioned(
                bottom: -10,
                top: 00.0,
                left: 10.0,
                child: TiltParallax(
                  size: const Offset(-50, -50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(),
                    ),
                    width: itemHeight / 2.5,
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                top: 00.0,
                left: 10.0,
                child: TiltParallax(
                  size: const Offset(-25, -25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(),
                    ),
                    width: itemHeight / 2.5,
                  ),
                ),
              ),
            ],
          ),
          child: HoverCardBook(
            book: book,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: buildCoverImage(coverPath ?? ''),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          book.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: CommonServices.calculateTextSize(_crossAxisCount),
          ),
        ),
      ],
    );
  }

  Widget _buildLibrarianMode(Book book, String? coverPath) {
    return Container(
      height: CommonServices.calculateItemHeight(_crossAxisCount),
      child: Card(
        elevation: 4,
        color: Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: buildCoverImage(coverPath ?? ''),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            CommonServices.calculateTextSize(_crossAxisCount) *
                            0.9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Autor: ${book.author}",
                      style: TextStyle(
                        fontSize:
                            CommonServices.calculateTextSize(_crossAxisCount) *
                            0.7,
                      ),
                    ),
                    Text(
                      "ID: ${book.id}",
                      style: TextStyle(
                        fontSize:
                            CommonServices.calculateTextSize(_crossAxisCount) *
                            0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(
    BuildContext context,
    Book book,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe tocar un botón para cerrar
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '¿Estás seguro de que quieres eliminar el libro "${book.title}"?',
                ),
                const SizedBox(height: 8),
                const Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el diálogo primero
                try {
                  await BookServices.deleteBook(context, book);
                  // Opcional: Mostrar mensaje de éxito
                  CustomSnackBar.show(
                    context,
                    '"${book.title}" eliminado correctamente',
                    Colors.green,
                    duration: Duration(seconds: 4),
                  );
                } catch (e) {
                  CustomSnackBar.show(
                    context,
                    'Error al eliminar: ${e.toString()}',
                    Colors.red,
                    duration: Duration(seconds: 4),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
