import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/comic_metadata_search_dialog.dart';
import 'package:inkger/frontend/dialogs/convert_comic_options_dialog.dart';
import 'package:inkger/frontend/dialogs/add_to_reading_list_dialog.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/utils/comic_filter_provider.dart';
import 'package:inkger/frontend/utils/comic_list_item.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/comic_view_switcher.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/frontend/widgets/hover_card_comic.dart';
import 'package:inkger/frontend/widgets/reading_progress_bar.dart';
import 'package:inkger/frontend/widgets/sort_selector.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkger/frontend/widgets/comics_filters_layout.dart';
import '../services/reading_list_services.dart';

enum ViewMode { simple, threeD, librarian }

class ComicsGrid extends StatefulWidget {
  const ComicsGrid({super.key});

  @override
  State<ComicsGrid> createState() => _ComicsGridState();
}

class _ComicsGridState extends State<ComicsGrid> {
  int? _count;
  double _crossAxisCount = 5;
  ViewMode _selectedViewMode = ViewMode.simple;
  SortCriteria _sortCriteria = SortCriteria.creationDate;
  bool _sortAscending = true;
  final ValueNotifier<Color> _dominantColorNotifier = ValueNotifier<Color>(
    Colors.grey,
  ); // Color por defecto
  //late Future<Color> _dominantColorFuture;
  //bool _colorCalculated = false

  final List<Comic> _selectedComics =
      []; // Lista para almacenar los cómics seleccionados

  @override
  void dispose() {
    _dominantColorNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComics();
      _updateComicCount();
    });
  }

  Future<void> _updateComicCount() async {
    final count = await CommonServices.fetchComicCount();
    if (mounted) {
      setState(() {
        _count = count;
      });
    }
  }

  Future<void> _loadComics() async {
    final provider = Provider.of<ComicsProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    // Campos requeridos
    final id = prefs.getInt('id');
    await provider.loadcomics(id ?? 0);

    final comics = Provider.of<ComicsProvider>(context, listen: false).comics;
    final filters = Provider.of<ComicFilterProvider>(context, listen: false);

    // Escritores únicos (con manejo de nulos)
    final writers =
        comics
            .map((b) => b.writer)
            .where((a) => a != null && a.trim().isNotEmpty)
            .expand((a) => a!.split(','))
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    filters.fillWriters(writers);

    // Personajes únicos (con manejo de nulos)
    final characters =
        comics
            .map((b) => b.characters)
            .where((a) => a != null && a.trim().isNotEmpty)
            .expand((a) => a!.split(','))
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    filters.fillCharacters(characters);

    // Localizaciones únicos (con manejo de nulos)
    final locations =
        comics
            .map((b) => b.locations)
            .where((a) => a != null && a.trim().isNotEmpty)
            .expand((a) => a!.split(','))
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    filters.fillLocations(locations);

    // Equipos únicos (con manejo de nulos)
    final teams =
        comics
            .map((b) => b.teams)
            .where((a) => a != null && a.trim().isNotEmpty)
            .expand((a) => a!.split(','))
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    filters.fillTeams(teams);

    // Series únicas (con manejo de nulos)
    final series =
        comics
            .map((b) => b.series)
            .where((a) => a != null && a.trim().isNotEmpty)
            .expand((a) => a!.split(','))
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    filters.fillSeries(series);

    // Arcos únicos (con manejo de nulos)
    final storyArc =
        comics
            .map((b) => b.storyArc)
            .where((a) => a != null && a.trim().isNotEmpty)
            .expand((a) => a!.split(','))
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    filters.fillStoryArcs(storyArc);

    // Publishers únicos (con manejo de nulos)
    final publishers =
        comics
            .map((b) => b.publisher?.trim() ?? '') // Manejo de publisher null
            .where((p) => p.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    filters.fillPublishers(publishers);
  }

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<ComicFilterProvider>(context);
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
                  ComicViewSwitcher(),
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
            if (_selectedComics.isNotEmpty && !filters.isGridView)
              Row(
                children: [
                  Tooltip(
                    message: "Eliminar cómics seleccionados",
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _deleteSelectedComics();
                      },
                    ),
                  ),
                  Tooltip(
                    message: "Marcar cómics como leídos",
                    child: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () async {
                        await _markAsRead();
                      },
                    ),
                  ),
                  Tooltip(
                    message: "Marcar cómics como no leídos",
                    child: IconButton(
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Colors.orange,
                      ),
                      onPressed: () async {
                        await _markAsUnread();
                      },
                    ),
                  ),
                  Tooltip(
                    message: "Añadir cómics a la lista de lectura",
                    child: IconButton(
                      icon: const Icon(Icons.playlist_add, color: Colors.blue),
                      onPressed: () async {
                        await _addToReadingList();
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Consumer<ComicFilterProvider>(
            builder: (context, filterProvider, child) {
              if (filters.isFilterMenuVisible) {
                return const ComicsFiltersLayout();
              }

              if (filterProvider.selectedPublishers.isEmpty &&
                  filterProvider.selectedCharacters.isEmpty &&
                  filterProvider.selectedLocations.isEmpty &&
                  filterProvider.selectedSeries.isEmpty &&
                  filterProvider.selectedStoryArcs.isEmpty &&
                  filterProvider.selectedTeams.isEmpty &&
                  filterProvider.selectedWriters.isEmpty) {
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
                    ...filterProvider.selectedWriters.map((writer) {
                      return Chip(
                        label: Text("Escritor: $writer"),
                        deleteIcon: Icon(Icons.clear),
                        onDeleted: () {
                          // Eliminar autor del provider
                          filterProvider.removeWriter(writer);
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

                    // Mostrar chips de personajes seleccionados
                    ...filterProvider.selectedCharacters.map((character) {
                      return Chip(
                        label: Text("Personaje: $character"),
                        deleteIcon: Icon(Icons.clear),
                        onDeleted: () {
                          // Eliminar publisher del provider
                          filterProvider.removeCharacter(character);
                        },
                      );
                    }),
                    // Mostrar chips de localizaciones seleccionados
                    ...filterProvider.selectedLocations.map((location) {
                      return Chip(
                        label: Text("Localizacion: $location"),
                        deleteIcon: Icon(Icons.clear),
                        onDeleted: () {
                          // Eliminar publisher del provider
                          filterProvider.removeLocation(location);
                        },
                      );
                    }),
                    // Mostrar chips de series seleccionados
                    ...filterProvider.selectedSeries.map((serie) {
                      return Chip(
                        label: Text("Serie: $serie"),
                        deleteIcon: Icon(Icons.clear),
                        onDeleted: () {
                          // Eliminar publisher del provider
                          filterProvider.removeSeries(serie);
                        },
                      );
                    }),
                    // Mostrar chips de equipos seleccionados
                    ...filterProvider.selectedTeams.map((team) {
                      return Chip(
                        label: Text("Equipo: $team"),
                        deleteIcon: Icon(Icons.clear),
                        onDeleted: () {
                          // Eliminar publisher del provider
                          filterProvider.removeTeam(team);
                        },
                      );
                    }),
                    // Mostrar chips de series seleccionados
                    ...filterProvider.selectedStoryArcs.map((arc) {
                      return Chip(
                        label: Text("Arco: $arc"),
                        deleteIcon: Icon(Icons.clear),
                        onDeleted: () {
                          // Eliminar publisher del provider
                          filterProvider.removeStoryArc(arc);
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
                "Comics - (${_count.toString()})",
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

                return Consumer<ComicsProvider>(
                  builder: (context, booksProvider, _) {
                    final books = booksProvider.comics;
                    final filteredBooks = _filterBooks(books);

                    if (books.isEmpty) {
                      return Center(child: Text("No hay comics disponibles"));
                    }

                    if (filters.isGridView) {
                      _onViewModeChanged(true);
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
                          final comic = filteredBooks[index];
                          return ComicListItem(
                            comic: comic,
                            isSelected: _selectedComics.contains(comic),
                            onSelected: (isSelected) {
                              setState(() {
                                if (isSelected == true) {
                                  _selectedComics.add(comic);
                                } else {
                                  _selectedComics.remove(comic);
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
          //_buildSelectedComicsJson(),
        ],
      ),
    );
  }

  // Función para filtrar los libros
  List<Comic> _filterBooks(List<Comic> books) {
    final filters = Provider.of<ComicFilterProvider>(context, listen: false);

    List<Comic> filtered = books.where((book) {
      final writerList =
          book.writer
              ?.split(',')
              .map((w) => w.trim())
              .where((w) => w.isNotEmpty)
              .toList() ??
          [];

      final characterList =
          book.characters
              ?.split(',')
              .map((w) => w.trim())
              .where((w) => w.isNotEmpty)
              .toList() ??
          [];
      final teamList =
          book.teams
              ?.split(',')
              .map((w) => w.trim())
              .where((w) => w.isNotEmpty)
              .toList() ??
          [];
      final locationList =
          book.locations
              ?.split(',')
              .map((w) => w.trim())
              .where((w) => w.isNotEmpty)
              .toList() ??
          [];
      final seriesList =
          book.series
              ?.split(',')
              .map((w) => w.trim())
              .where((w) => w.isNotEmpty)
              .toList() ??
          [];
      final storyArcList =
          book.storyArc
              ?.split(',')
              .map((w) => w.trim())
              .where((w) => w.isNotEmpty)
              .toList() ??
          [];

      final matchesAuthor =
          filters.selectedWriters.isEmpty ||
          writerList.any((w) => filters.selectedWriters.contains(w));

      final matchesPublisher =
          filters.selectedPublishers.isEmpty ||
          filters.selectedPublishers.contains(book.publisher?.trim() ?? '');

      final matchesCharacter =
          filters.selectedCharacters.isEmpty ||
          characterList.any((w) => filters.selectedCharacters.contains(w));

      final matchesTeam =
          filters.selectedTeams.isEmpty ||
          teamList.any((w) => filters.selectedTeams.contains(w));

      final matchesLocation =
          filters.selectedLocations.isEmpty ||
          locationList.any((w) => filters.selectedLocations.contains(w));

      final matchesSeries =
          filters.selectedSeries.isEmpty ||
          seriesList.any((w) => filters.selectedSeries.contains(w));

      final matchesStoryArc =
          filters.selectedStoryArcs.isEmpty ||
          storyArcList.any((w) => filters.selectedStoryArcs.contains(w));

      return matchesAuthor &&
          matchesPublisher &&
          matchesCharacter &&
          matchesLocation &&
          matchesSeries &&
          matchesStoryArc &&
          matchesTeam;
    }).toList();

    filtered.sort((a, b) {
      int cmp;
      switch (_sortCriteria) {
        case SortCriteria.creationDate:
          cmp = a.creationDate.compareTo(b.creationDate);
          break;
        case SortCriteria.publicationDate:
          cmp = a.publicationDate!.compareTo(b.publicationDate!);
          break;
        case SortCriteria.author:
          cmp = a.writer!.toLowerCase().compareTo(b.writer!.toLowerCase());
          break;
        case SortCriteria.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    return filtered;
  }

  Widget _buildSimpleMode(
    BuildContext context,
    Comic comic,
    String? coverPath,
  ) {
    return Column(
      children: [
        HoverCardComic(
          comic: comic,
          onAddToList: () async {
            _selectedComics.add(comic);
            await _addToReadingList();
          },
          onDownload: () async {
            final filePath = comic.filePath;
            String extension = '';
            if (filePath != null && filePath.contains('.')) {
              extension = filePath.substring(filePath.lastIndexOf('.') + 1);
            }
            await CommonServices.downloadFile(
              comic.id,
              comic.title,
              extension,
              "comic",
            );
          },
          onConvert: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConvertOptionsDialog(comicId: comic.id);
            },
          ),
          onSearchMetadata: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return ComicMetadataSearchDialog(comic: comic);
            },
          ),
          onDelete: () =>
              ComicServices.showDeleteConfirmationDialog(context, comic),
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
                        color: comic.readingProgress!['read'] == true
                            ? Colors.green.withOpacity(0.8)
                            : Colors.red.withOpacity(0.8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        comic.readingProgress!['read'] == true
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
                      value: comic.readingProgress!['readingProgress'],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Column(
          children: [
            Text(
              comic.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: CommonServices.calculateTextSize(_crossAxisCount),
              ),
            ),
            Text(
              comic.writer ?? '',
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

  Future<void> _deleteSelectedComics() async {
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
        final provider = Provider.of<ComicsProvider>(context, listen: false);
        final idsToDelete = _selectedComics
            .map((comic) => int.parse(comic.id.toString()))
            .toList();
        await ComicServices.deleteComics(idsToDelete);

        setState(() {
          for (var comic in _selectedComics) {
            provider.removeComic(comic.id); // Eliminar del provider
          }
          _selectedComics.clear();
        });
        await _updateComicCount(); // Actualizar el conteo de cómics
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

  Future<void> _markAsRead() async {
    final provider = Provider.of<ComicsProvider>(context, listen: false);
    for (var comic in _selectedComics) {
      comic.readingProgress!['read'] = true;
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('id');
      await ComicServices.saveReadState(comic.id, true, context);
      await provider.loadcomics(id ?? 0);
      provider.updatecomic(comic); // Actualizar en el provider
    }
    CustomSnackBar.show(
      context,
      "Cómics marcados como leídos",
      Colors.green,
      duration: Duration(seconds: 4),
    );
  }

  Future<void> _markAsUnread() async {
    final provider = Provider.of<ComicsProvider>(context, listen: false);
    for (var comic in _selectedComics) {
      comic.readingProgress!['read'] = false;
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('id');
      await ComicServices.saveReadState(comic.id, false, context);
      await provider.loadcomics(id ?? 0);
      provider.updatecomic(comic); // Actualizar en el provider
    }
    CustomSnackBar.show(
      context,
      "Cómics marcados como no leídos",
      Colors.orange,
      duration: Duration(seconds: 4),
    );
  }

  Future<void> _addToReadingList() async {
    // Show the dialog once to get the selected reading list
    final selectedListId = await showDialog<String>(
      // Changed return type to String? (for list ID)
      context: context,
      builder: (BuildContext context) =>
          AddToReadingListDialog(), // No comic-specific data needed here
    );

    // If a list was selected, proceed to add comics
    if (selectedListId != null) {
      for (var comic in _selectedComics) {
        try {
          await ReadingListServices.addItemToList(
            int.parse(selectedListId), // Use the selected list ID
            comic.id,
            'comic',
            comic.title,
            comic.series!,
            comic.coverPath!,
          );
        } catch (e) {
          // Handle error for individual comic addition
          print('Error adding ${comic.title} to list: $e');
          // You might want to show a less intrusive message or log this.
        }
      }
      CustomSnackBar.show(
        context,
        "Cómics añadidos a la lista de lectura",
        Colors.blue,
        duration: Duration(seconds: 4),
      );
    } else {
      // User cancelled the dialog
      CustomSnackBar.show(
        context,
        "Ningún cómic fue añadido a la lista de lectura",
        Colors.orange,
        duration: Duration(seconds: 3),
      );
    }
  }

  void _onViewModeChanged(bool gridMode) {
    if (gridMode) {
      _selectedComics.clear();
    }
  }
}
