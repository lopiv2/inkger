import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
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
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkger/frontend/widgets/comics_filters_layout.dart';

enum ViewMode { simple, threeD, librarian }

class ComicsGrid extends StatefulWidget {
  const ComicsGrid({super.key});

  @override
  State<ComicsGrid> createState() => _ComicsGridState();
}

class _ComicsGridState extends State<ComicsGrid> {
  int? _count;
  double _crossAxisCount = 5;
  final double _minCrossAxisCount = 5;
  final double _maxCrossAxisCount = 10;
  ViewMode _selectedViewMode = ViewMode.simple;
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
      _loadComics();
      _updateComicCount();
      final prefs = Provider.of<PreferencesProvider>(context, listen: false);
      setState(() {
        _crossAxisCount = prefs.preferences.defaultGridItemSize;
      });
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.3),
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
              onChanged: (value) {
                setState(() {
                  _crossAxisCount = value;
                });
              },
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
                double maxHeight = constraints.maxHeight;
                double itemHeight = CommonServices.calculateMainAxisExtent(
                  _crossAxisCount,
                ).toDouble();

                // Si el itemHeight es mayor que el espacio disponible, limitarlo
                if (itemHeight * (_crossAxisCount / 2) > maxHeight) {
                  itemHeight = maxHeight / (_crossAxisCount / 5);
                }
                return Consumer<ComicsProvider>(
                  builder: (context, ComicsProvider, child) {
                    final comics = ComicsProvider.comics;
                    // Filtrar libros según los filtros activos
                    final filteredComics = _filterBooks(comics);
                    if (comics.isEmpty)
                      return Center(child: Text("No hay comics disponibles"));
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
                        itemCount: filteredComics.length,
                        itemBuilder: (context, index) {
                          final comic = filteredComics[index];
                          final coverPath = comic.coverPath;

                          switch (_selectedViewMode) {
                            case ViewMode.simple:
                              return _buildSimpleMode(
                                context,
                                comic,
                                coverPath,
                              );
                            case ViewMode.threeD:
                              return _build3DMode(
                                context,
                                comic,
                                coverPath,
                                itemHeight,
                              );
                            case ViewMode.librarian:
                              return _buildLibrarianMode(comic, coverPath);
                          }
                        },
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredComics.length,
                        itemBuilder: (context, index) =>
                            ComicListItem(comic: filteredComics[index]),
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
  List<Comic> _filterBooks(List<Comic> books) {
    final filters = Provider.of<ComicFilterProvider>(context, listen: false);

    return books.where((book) {
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
          onAddToList: () => showDialog(
            context: context,
            builder: (BuildContext context) => AddToReadingListDialog(
              id: comic.id,
              type: 'comic',
              series: comic.series,
              title: comic.title,
            ),
          ),
          onDownload: () async {
            final filePath = comic.filePath;
            String extension = '';
            if (filePath != null && filePath.contains('.')) {
              extension = filePath.substring(filePath.lastIndexOf('.'));
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
          onDelete: () => showDeleteConfirmationDialog(context, comic),
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

  Widget _build3DMode(
    BuildContext context,
    Comic comic,
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
          child: HoverCardComic(
            comic: comic,
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
          comic.title,
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

  Widget _buildLibrarianMode(Comic comic, String? coverPath) {
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
                      comic.title,
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
                      "Autor: ${comic.writer}",
                      style: TextStyle(
                        fontSize:
                            CommonServices.calculateTextSize(_crossAxisCount) *
                            0.7,
                      ),
                    ),
                    Text(
                      "ID: ${comic.id}",
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
    Comic comic,
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
                  '¿Estás seguro de que quieres eliminar el libro "${comic.title}"?',
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
                  await ComicServices.deletecomic(context, comic);
                  // Opcional: Mostrar mensaje de éxito
                  CustomSnackBar.show(
                    context,
                    '"${comic.title}" eliminado correctamente',
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
