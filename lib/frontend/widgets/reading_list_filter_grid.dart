import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/models/reading_list.dart';
import 'package:inkger/frontend/models/reading_list_item.dart';
import 'package:inkger/frontend/services/reading_list_services.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';

class ReadingListFilterAndGrid extends StatefulWidget {
  final List<ReadingList> readingLists; // Cambia el tipo a List<ReadingList>.

  const ReadingListFilterAndGrid({Key? key, required this.readingLists})
    : super(key: key);

  @override
  _ReadingListFilterAndGridState createState() =>
      _ReadingListFilterAndGridState();
}

class _ReadingListFilterAndGridState extends State<ReadingListFilterAndGrid> {
  String _currentFilter = '#';
  late Set<String> _availableLetters = {};
  late List<ReadingList> _readingLists;

  @override
  void initState() {
    super.initState();
    _readingLists = widget.readingLists; // Inicializa las listas de lectura.
    _loadLetters(_readingLists); // Carga las letras disponibles.
  }

  // Filtrar las listas de lectura de acuerdo con el filtro alfabético.
  List<ReadingList> _filterReadingLists(
    List<ReadingList> readingLists,
    String filter,
  ) {
    if (filter == '#') {
      return readingLists
          .where(
            (list) => list.title[0].contains(RegExp(r'[^a-zA-Z]')),
          ) // Coincide con cualquier carácter que no sea una letra
          .toList();
    }
    return readingLists
        .where((list) => list.title[0].toLowerCase() == filter.toLowerCase())
        .toList();
  }

  void _loadLetters(List<ReadingList> readingLists) {
    if (_availableLetters.isEmpty) {
      Set<String> letters = {};
      for (var list in readingLists) {
        String firstChar = list.title[0].toLowerCase();
        if (RegExp(r'[a-z]').hasMatch(firstChar)) {
          letters.add(firstChar);
        } else {
          letters.add('#');
        }
      }
      _availableLetters = letters;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLists = _filterReadingLists(_readingLists, _currentFilter);

    return Column(
      children: [
        // Filtro alfabético
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAlphabetFilter('#'),
              ...List.generate(26, (index) {
                final letter = String.fromCharCode('A'.codeUnitAt(0) + index);
                return _buildAlphabetFilter(letter);
              }),
            ],
          ),
        ),
        // Grid de listas de lectura
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredLists.length,
              itemBuilder: (context, index) {
                final list = filteredLists[index];
                return _buildReadingListCard(
                  list.id,
                  list.title,
                  list.coverUrl ?? '',
                  list.items.length,
                  list.items,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlphabetFilter(String letter) {
    bool isEnabled = _availableLetters.contains(letter.toLowerCase());
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: isEnabled ? () => setState(() => _currentFilter = letter) : null,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _currentFilter == letter
                ? Theme.of(context).primaryColor
                : isEnabled
                ? Colors.grey[400]
                : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                color: _currentFilter == letter
                    ? Colors.white
                    : isEnabled
                    ? Colors.black
                    : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadingListCard(
    String? id,
    String title,
    String coverUrl,
    int count,
    List<ReadingListItem> items,
  ) {
    return FutureBuilder<List<String>>(
      future: ReadingListServices.fetchItemCovers(
        items,
      ), // Llamada a la API para obtener las portadas
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CustomLoader(size: 60.0, color: Colors.blue),
          ); // Mostrar un indicador de carga
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error al cargar portadas'),
          ); // Manejar errores
        } else {
          final itemCovers = snapshot.data ?? [];
          return Column(
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(
                    8,
                  ), // Asegurar que la propiedad margin esté definida
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navegación con GoRouter
                      context.push(
                        '/reading-lists/${Uri.encodeComponent(title)}', // Codificamos el título para URLs
                        extra: {
                          'id': id,
                          'title': title,
                          'coverUrl': coverUrl,
                          'count': count,
                          'items': items,
                        }, // Pasamos todos los datos de la lista de lectura como un mapa
                      );
                    },
                    hoverColor: Colors.black.withOpacity(0.1),
                    highlightColor: Colors.black.withOpacity(0.2),
                    splashColor: Colors.black.withOpacity(0.3),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: itemCovers.isNotEmpty
                                ? buildMultiCover(
                                    itemCovers,
                                  ) // Construir portada con múltiples imágenes
                                : buildCoverImage(
                                    coverUrl,
                                  ), // Construir portada con una sola imagen
                          ),
                        ),
                        /*Positioned(
                          bottom: 10,
                          left: 10,
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 5,
                                  color: Colors.black,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ),*/
                        Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
