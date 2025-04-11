import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/models/series.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';

class SeriesFilterAndGrid extends StatefulWidget {
  final Future<List<Series>> seriesFuture;

  const SeriesFilterAndGrid({Key? key, required this.seriesFuture})
    : super(key: key);

  @override
  _SeriesFilterAndGridState createState() => _SeriesFilterAndGridState();
}

class _SeriesFilterAndGridState extends State<SeriesFilterAndGrid> {
  String _currentFilter = '#';
  late Set<String> _availableLetters = {};
  List<Series>? _seriesList;

  // Filtrar la lista de series de acuerdo con el filtro alfabético
  List<Series> _filterSeries(List<Series> series, String filter) {
    if (filter == '#') {
      return series
          .where((s) => s.title[0].toLowerCase().contains(RegExp(r'[0-9]')))
          .toList();
    }
    return series
        .where((s) => s.title[0].toLowerCase() == filter.toLowerCase())
        .toList();
  }

  void _loadLetters(List<Series> seriesList) {
    if (_availableLetters.isEmpty) {
      Set<String> letters = {};
      for (var series in seriesList) {
        String firstChar = series.title[0].toLowerCase();
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
    return FutureBuilder<List<Series>>(
      future: widget.seriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay series disponibles.'));
        }

        final seriesList = snapshot.data!;
        _seriesList ??= seriesList; // ← guarda la lista una sola vez
        _loadLetters(seriesList);
        final filteredSeries = _filterSeries(seriesList, _currentFilter);

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
            // Grid de series
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
                  itemCount: filteredSeries.length,
                  itemBuilder: (context, index) {
                    final series = filteredSeries[index];
                    return _buildSeriesCard(
                      series.title,
                      series.coverPath,
                      series.itemCount,
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

  Widget _buildSeriesCard(String title, String coverPath, int count) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navegación con GoRouter
          context.push(
            '/series/${Uri.encodeComponent(title)}', // Codificamos el título para URLs
            extra: coverPath, // Pasamos la ruta de la portada como extra
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
                child: buildCoverImage(coverPath),
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
