import 'package:flutter/material.dart';

class SeriesFilterAndGrid extends StatefulWidget {
  final Future<List<String>> seriesFuture;

  const SeriesFilterAndGrid({Key? key, required this.seriesFuture})
    : super(key: key);

  @override
  _SeriesFilterAndGridState createState() => _SeriesFilterAndGridState();
}

class _SeriesFilterAndGridState extends State<SeriesFilterAndGrid> {
  String _currentFilter = '#';
  late Set<String> _availableLetters =
      {}; // Para almacenar las letras con series

  List<String> _filterSeries(List<String> series, String filter) {
    if (filter == '#') {
      return series
          .where((s) => s[0].toLowerCase().contains(RegExp(r'[0-9]')))
          .toList();
    }
    return series
        .where((s) => s[0].toLowerCase() == filter.toLowerCase())
        .toList();
  }

  // Determinar las letras que tienen series
  void _determineAvailableLetters(List<String> series) {
    Set<String> availableLetters = Set();

    for (var seriesName in series) {
      String firstLetter = seriesName[0].toLowerCase();
      if (RegExp(r'[a-zA-Z]').hasMatch(firstLetter)) {
        availableLetters.add(firstLetter);
      }
      if (RegExp(r'[0-9]').hasMatch(firstLetter)) {
        availableLetters.add('#');
      }
    }

    // Schedule setState to run after the current build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _availableLetters = availableLetters;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: widget.seriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allSeries = snapshot.data!;
        _determineAvailableLetters(
          allSeries,
        ); // Determine which letters have series
        final filteredSeries = _filterSeries(allSeries, _currentFilter);

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
                    crossAxisCount: 8, // Dos columnas
                    crossAxisSpacing: 8, // Espacio entre columnas
                    mainAxisSpacing: 8, // Espacio entre filas
                    childAspectRatio:
                        0.8, // Relación de aspecto para las tarjetas
                  ),
                  itemCount: filteredSeries.length,
                  itemBuilder: (context, index) {
                    return _buildSeriesCard(filteredSeries[index]);
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
        onTap:
            isEnabled
                ? () {
                  setState(() {
                    _currentFilter = letter;
                  });
                }
                : null, // Deshabilitar la acción si no tiene series
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                _currentFilter == letter
                    ? Theme.of(context).primaryColor
                    : isEnabled
                    ? Colors.grey[400]
                    : Colors.grey[50], // Gris si está deshabilitado
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
                        : Colors
                            .black54, // Gris más claro si está deshabilitado
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesCard(String seriesName) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      child: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://via.placeholder.com/150', // Aquí va la URL de la imagen
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Título de la serie
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              seriesName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.black.withOpacity(0.7),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          // Número en la parte superior derecha
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                '${(seriesName[0].codeUnitAt(0) % 10)}', // Número de ejemplo
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
