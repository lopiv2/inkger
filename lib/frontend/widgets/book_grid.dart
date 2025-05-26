import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:inkger/frontend/dialogs/add_to_reading_list_dialog.dart';
import 'package:inkger/frontend/dialogs/book_metadata_search_dialog.dart';
import 'package:inkger/frontend/dialogs/convert_ebook_options_dialog.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/utils/book_filter_provider.dart';
import 'package:inkger/frontend/utils/book_list_item.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/book_view_switcher.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/frontend/widgets/hover_card_book.dart';
import 'package:inkger/frontend/widgets/reading_progress_bar.dart';
import 'package:inkger/frontend/widgets/sort_selector.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:inkger/frontend/widgets/book_filters_layout.dart';

import 'package:shared_preferences/shared_preferences.dart';

enum ViewMode { simple, threeD, librarian }

class BooksGrid extends StatefulWidget {
  @override
  State<BooksGrid> createState() => _BooksGridState();
}

class _BooksGridState extends State<BooksGrid> {
  int? _count;
  double _crossAxisCount = 5;
  final double _minCrossAxisCount = 5;
  final double _maxCrossAxisCount = 10;
  ViewMode _selectedViewMode = ViewMode.simple;
  SortCriteria _sortCriteria = SortCriteria.creationDate;
  bool _sortAscending = true;
  final ValueNotifier<Color> _dominantColorNotifier = ValueNotifier<Color>(
    Colors.grey,
  ); // Color por defecto
  //late Future<Color> _dominantColorFuture;
  //bool _colorCalculated = false;

  @override
  void dispose() {
    _dominantColorNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBooks();
      _updateBookCount();
      final prefs = Provider.of<PreferencesProvider>(context, listen: false);
      if (!mounted) return; // ⛔️ Si ya fue desmontado, salimos
      setState(() {
        _crossAxisCount = prefs.preferences.defaultGridItemSize;
      });
    });
  }

  Future<void> _updateBookCount() async {
    final count = await CommonServices.fetchBookCount();
    if (mounted) {
      setState(() {
        _count = count;
      });
    }
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

      // Tags únicos (con manejo de nulos)
      final tags =
          books
              .where((b) => b.tags != null && b.tags!.isNotEmpty)
              .expand((b) => b.tags!.split(','))
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      filters.fillTags(tags);
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                  BooksSortSelector(
                    selectedCriteria: _sortCriteria,
                    ascending: _sortAscending,
                    onCriteriaChanged: (criteria) {
                      setState(() {
                        _sortCriteria = criteria;
                      });
                    },
                    onToggleDirection: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                  Text("Modo:", style: TextStyle(fontSize: 14)),
                  Radio<ViewMode>(
                    value: ViewMode.simple,
                    groupValue: _selectedViewMode,
                    onChanged: (value) =>
                        setState(() => _selectedViewMode = value!),
                  ),
                  Text(
                    "Simple",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Radio<ViewMode>(
                    value: ViewMode.threeD,
                    groupValue: _selectedViewMode,
                    onChanged: (value) =>
                        setState(() => _selectedViewMode = value!),
                  ),
                  Text(
                    "3D",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Radio<ViewMode>(
                    value: ViewMode.librarian,
                    groupValue: _selectedViewMode,
                    onChanged: (value) =>
                        setState(() => _selectedViewMode = value!),
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
              if (filterProvider.isFilterMenuVisible) {
                return const BookFiltersLayout();
              }

              if (filterProvider.selectedAuthors.isEmpty &&
                  filterProvider.selectedPublishers.isEmpty &&
                  filterProvider.selectedTags.isEmpty) {
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
                    // Mostrar chips de publishers seleccionados
                    ...filterProvider.selectedTags.map((tag) {
                      return Chip(
                        label: Text("Etiqueta: $tag"),
                        deleteIcon: Icon(Icons.clear),
                        onDeleted: () {
                          // Eliminar publisher del provider
                          filterProvider.removeTag(tag);
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
                "${AppLocalizations.of(context)!.books} - (${_count.toString()})",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxHeight = constraints.maxHeight;
                double itemHeight = CommonServices.calculateMainAxisExtent(
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
                        itemBuilder: (context, index) =>
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

  // Función para filtrar los libros
  List<Book> _filterBooks(List<Book> books) {
    final filters = Provider.of<BookFilterProvider>(context, listen: false);

    List<Book> filtered = books.where((book) {
      final matchesAuthor =
          filters.selectedAuthors.isEmpty ||
          filters.selectedAuthors.contains(book.author.trim());

      final matchesPublisher =
          filters.selectedPublishers.isEmpty ||
          filters.selectedPublishers.contains(book.publisher?.trim() ?? '');

      final matchesTag =
          filters.selectedTags.isEmpty ||
          (book.tags != null &&
              book.tags!
                  .split(',')
                  .map((tag) => tag.trim())
                  .any((tag) => filters.selectedTags.contains(tag)));

      return matchesAuthor && matchesPublisher && matchesTag;
    }).toList();

    filtered.sort((a, b) {
      int cmp;
      switch (_sortCriteria) {
        case SortCriteria.creationDate:
          cmp = a.creationDate!.compareTo(b.creationDate!);
          break;
        case SortCriteria.publicationDate:
          cmp = a.publicationDate.compareTo(b.publicationDate);
          break;
        case SortCriteria.author:
          cmp = a.author.toLowerCase().compareTo(b.author.toLowerCase());
          break;
        case SortCriteria.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    return filtered;
  }

  Widget _buildSimpleMode(BuildContext context, Book book, String? coverPath) {
    return Column(
      children: [
        HoverCardBook(
          book: book,
          onDelete: () => showDeleteConfirmationDialog(context, book),
          onConvert: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConvertEbookOptionsDialog(ebookId: book.id);
            },
          ),
          onGetMetadata: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return BookSearchDialog(book: book);
            },
          ),
          onDownload: () async {
            final filePath = book.filePath;
            String extension = '';
            if (filePath != null && filePath.contains('.')) {
              extension = filePath.substring(filePath.lastIndexOf('.'));
            }
            await CommonServices.downloadFile(
              book.id,
              book.title,
              extension,
              "book",
            );
          },
          onAddToList: () => showDialog(
            context: context,
            builder: (BuildContext context) => AddToReadingListDialog(
              id: book.id,
              type: 'book',
              series: book.series,
              title: book.title,
            ),
          ),
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
                    child: ReadingProgressBarIndicator(
                      value: book.readingProgress!['readingProgress'],
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
            onAddToList: () => showDialog(
              context: context,
              builder: (BuildContext context) => AddToReadingListDialog(
                id: book.id,
                type: 'book',
                series: book.series,
                title: book.title,
              ),
            ),
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
              child: Text(AppLocalizations.of(context)!.cancel),
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
