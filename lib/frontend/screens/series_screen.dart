import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/models/series.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/widgets/series_filter_grid.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeriesScreen extends StatefulWidget {
  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComics();
  }

  Future<void> _loadComics() async {
    final provider = Provider.of<ComicsProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt('id');
    if (id != null) {
      await provider.loadcomics(id);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context);
    final comicsProvider = Provider.of<ComicsProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final uniqueSeries = _getUniqueSeries(context,booksProvider.books, comicsProvider.comics);

    return Scaffold(
      appBar: AppBar(title: const Text('Series'), centerTitle: true),
      body: SeriesFilterAndGrid(
        seriesFuture: Future.value(uniqueSeries),
      ),
    );
  }
}

  List<Series> _getUniqueSeries(BuildContext context,List<Book> books, List<Comic> comics) {
    final Map<String, SeriesAggregator> seriesMap = {};

    void processItem(
      String originalTitle,
      String? coverPath,
      int? seriesNumber,
    ) {
      final normalizedTitle = originalTitle.trim().toLowerCase();
      final aggregator = seriesMap[normalizedTitle] ?? SeriesAggregator();

      aggregator.count++; // Incrementa el conteo
      // Si no se ha asignado aún la portada, la asigna
      if (coverPath != null &&
          coverPath.isNotEmpty &&
          aggregator.coverPath.isEmpty) {
        aggregator.coverPath = coverPath;
      }
      // Asignamos seriesNumber si aún no existe y se proporcionó
      if (seriesNumber != null && aggregator.seriesNumber == null) {
        aggregator.seriesNumber = seriesNumber;
      }
      // Guardar el título original (capitalizado o tal cual)
      if (aggregator.originalTitle.isEmpty) {
        aggregator.originalTitle = originalTitle.trim();
      }
      seriesMap[normalizedTitle] = aggregator;
    }

    // Procesa cada libro
    for (var book in books) {
      final seriesTitle = book.series ?? AppLocalizations.of(context)!.noSerie;
      processItem(seriesTitle, book.coverPath, book.seriesNumber);
    }

    // Procesa cada cómic
    for (var comic in comics) {
      final seriesTitle = comic.series ?? AppLocalizations.of(context)!.noSerie;
      processItem(seriesTitle, comic.coverPath, comic.seriesNumber);
    }

    // Convertir el mapa de agregadores a una lista de Series
    return seriesMap.values
        .map(
          (aggregator) => Series(
            title: aggregator.originalTitle,
            coverPath: aggregator.coverPath,
            seriesNumber: aggregator.seriesNumber ?? 0,
            itemCount: aggregator.count,
          ),
        )
        .toList();
  }


class SeriesAggregator {
  int count = 0;
  String coverPath = '';
  int? seriesNumber;
  String originalTitle = '';
}
