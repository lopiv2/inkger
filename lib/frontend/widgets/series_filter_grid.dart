import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/series.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
import 'package:inkger/frontend/widgets/hover_card_generic.dart';

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
          return const Center(child: CustomLoader(size: 60.0, color: Colors.blue));
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
                  padding: EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: filteredSeries.length,
                  itemBuilder: (context, index) {
                    final series = filteredSeries[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return _buildSeriesCard(
                          series.title,
                          series.coverPath,
                          series.itemCount,
                          maxHeight: constraints.maxHeight,
                        );
                      },
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

  Widget _buildSeriesCard(
    String title,
    String coverPath,
    int count, {
    double? maxHeight,
  }) {
    return Column(
      children: [
        HoverCardGeneric(
          title: title,
          coverPath: coverPath,
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
                  child: buildCoverImage(coverPath),
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
}
