import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/add_to_reading_list_dialog.dart';
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

import 'package:shared_preferences/shared_preferences.dart';

class BooksGrid extends StatefulWidget {
  @override
  State<BooksGrid> createState() => _BooksGridState();
}

class _BooksGridState extends State<BooksGrid> {
  int? _count;
  double _crossAxisCount = 5;
  SortCriteria _sortCriteria = SortCriteria.creationDate;
  bool _sortAscending = true;
  final ValueNotifier<Color> _dominantColorNotifier = ValueNotifier<Color>(
    Colors.grey,
  ); // Color por defecto
  //late Future<Color> _dominantColorFuture;
  //bool _colorCalculated = false;
  final List<Book> _selectedBooks =
      []; // Lista para almacenar los libros seleccionados
  final List<Map<String, dynamic>> _selectedBooksJson =
      []; // Lista para almacenar los datos seleccionados en JSON

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
      _updateBookCount();
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
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.3),
                ],
              ),
            ),
            if (_selectedBooks.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await _deleteSelectedBooks();
                },
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
                final screenWidth = constraints.maxWidth;
                final itemWidth = 200.0; // Ancho fijo para cada elemento
                final itemsPerRow = (screenWidth / itemWidth)
                    .floor(); // Calcular dinámicamente

                return Consumer<BooksProvider>(
                  builder: (context, booksProvider, _) {
                    final books = booksProvider.books;
                    final filteredBooks = _filterBooks(books);

                    if (books.isEmpty) {
                      return Center(child: Text("No hay libros disponibles"));
                    }

                    if (filters.isGridView) {
                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: filteredBooks.map((book) {
                            final coverPath = book.coverPath;
                            return SizedBox(
                              width:
                                  screenWidth / itemsPerRow -
                                  16, // Ajustar ancho dinámicamente
                              child: _buildSimpleMode(context, book, coverPath),
                            );
                          }).toList(),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          return BookListItem(
                            book: book,
                            isSelected: _selectedBooks.contains(book),
                            onSelected: (isSelected) {
                              setState(() {
                                if (isSelected == true) {
                                  _selectedBooks.add(book);
                                  _selectedBooksJson.add({
                                    'id': book.id,
                                    'title': book.title,
                                    'author': book.author,
                                  });
                                } else {
                                  _selectedBooks.remove(book);
                                  _selectedBooksJson.removeWhere(
                                    (item) => item['id'] == book.id,
                                  );
                                }
                              });
                            },
                          );
                        },
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
        filters.selectedPublishers.isNotEmpty ||
        filters.selectedTags.isNotEmpty;

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
                  // Chips de tags
                  ...filters.selectedTags.map((tag) {
                    return Chip(
                      label: Text('Etiqueta: $tag'),
                      onDeleted: () {
                        filters.removeTag(tag);
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
                        items: filters.availableAuthors.map((author) {
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
                        items: filters.availablePublishers.map((publisher) {
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
                const SizedBox(width: 32),
                // Columna de etiquetas
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Etiqueta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        hint: const Text('Selecciona etiquetas'),
                        items: filters.availableTags.map((tag) {
                          return DropdownMenuItem<String>(
                            value: tag,
                            child: Text(tag),
                          );
                        }).toList(),
                        onChanged: (selectedTag) {
                          if (selectedTag != null) {
                            filters.toggleTag(selectedTag);
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

    List<Book> filtered = books.where((book) {
      final writerList = book.author
          .split(',')
          .map((w) => w.trim())
          .where((w) => w.isNotEmpty)
          .toList();

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
          onAddToList: () => showDialog(
            context: context,
            builder: (BuildContext context) => AddToReadingListDialog(
              id: book.id,
              type: 'book',
              series: book.series!,
              title: book.title,
              coverUrl: book.coverPath,
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
                  child: buildCoverImage(
                    coverPath ?? '',
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                ),
                Positioned(
                  top: 15,
                  right: -25,
                  child: Transform.rotate(
                    angle: 0.785398, // 45 grados en radianes
                    child: Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        color: book.readingProgress!['read'] == true
                            ? Colors.green.withOpacity(0.8)
                            : Colors.red.withOpacity(0.8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        book.readingProgress!['read'] == true
                            ? 'Leído'
                            : 'No leído',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
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

  Future<void> _deleteSelectedBooks() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar los cómics seleccionados?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final provider = Provider.of<BooksProvider>(context, listen: false);
        final idsToDelete = _selectedBooks
            .map((book) => int.parse(book.id.toString()))
            .toList();
        await BookServices.deleteBooks(idsToDelete);

        setState(() {
          for (var book in _selectedBooks) {
            _selectedBooksJson.removeWhere((item) => item['id'] == book.id);
            provider.removeBook(book.id); // Eliminar del provider
          }
          _selectedBooks.clear();
        });
        await _updateBookCount(); // Actualizar el conteo de libros
        CustomSnackBar.show(
          context,
          "Elementos eliminados correctamente",
          Colors.green,
          duration: Duration(seconds: 4),
        );
      } catch (e) {
        CustomSnackBar.show(
          context,
          'Error al eliminar elementos: $e',
          Colors.red,
          duration: Duration(seconds: 4),
        );
      }
    }
  }
}
