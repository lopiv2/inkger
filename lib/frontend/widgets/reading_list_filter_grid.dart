import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/models/reading_list.dart';

class ReadingListFilterAndGrid extends StatefulWidget {
  final Future<List<ReadingList>> readingListsFuture;

  const ReadingListFilterAndGrid({Key? key, required this.readingListsFuture})
      : super(key: key);

  @override
  _ReadingListFilterAndGridState createState() =>
      _ReadingListFilterAndGridState();
}

class _ReadingListFilterAndGridState extends State<ReadingListFilterAndGrid> {
  String _currentFilter = '#';
  late Set<String> _availableLetters = {};
  List<ReadingList>? _readingLists;

  // Filtrar las listas de lectura de acuerdo con el filtro alfabético
  List<ReadingList> _filterReadingLists(List<ReadingList> readingLists, String filter) {
    if (filter == '#') {
      return readingLists
          .where((list) => list.title[0].toLowerCase().contains(RegExp(r'[0-9]')))
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
    return FutureBuilder<List<ReadingList>>(
      future: widget.readingListsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay listas de lectura disponibles.'));
        }

        final readingLists = snapshot.data!;
        _readingLists ??= readingLists; // ← guarda la lista una sola vez
        _loadLetters(readingLists);
        final filteredLists = _filterReadingLists(readingLists, _currentFilter);

        return Column(
          children: [
            // Filtro alfabético
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAlphabetFilter('#'),
                  ...List.generate(26, (index) {
                    final letter = String.fromCharCode(
                      'A'.codeUnitAt(0) + index,
                    );
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
                    crossAxisCount: 8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredLists.length,
                  itemBuilder: (context, index) {
                    final list = filteredLists[index];
                    return _buildReadingListCard(
                      list.title,
                      list.coverUrl!,
                      list.items.length,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
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
            color:
                _currentFilter == letter
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
                color:
                    _currentFilter == letter
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

  Widget _buildReadingListCard(String title, String coverUrl, int count) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navegación con GoRouter
          context.push(
            '/readingList/${Uri.encodeComponent(title)}', // Codificamos el título para URLs
            extra: coverUrl, // Pasamos la ruta de la portada como extra
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
                child: Image.network(coverUrl, fit: BoxFit.cover),
              ),
            ),
            Positioned(
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
            ),
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
    );
  }
}
