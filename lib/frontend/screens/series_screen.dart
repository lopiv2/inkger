import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/models/series.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/widgets/series_filter_grid.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeriesScreen extends StatefulWidget {
  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  @override
  void initState() {
    super.initState();
    // Usar WidgetsBinding para posponer la carga después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComics();
    });
  }

  Future<void> _loadComics() async {
    final provider = Provider.of<ComicsProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    // Campos requeridos
    final id = prefs.getInt('id');
    await provider.loadcomics(id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos las listas de libros y cómics desde sus respectivos providers
    final booksProvider = Provider.of<BooksProvider>(context);
    final comicsProvider = Provider.of<ComicsProvider>(context);

    // Unimos las listas de libros y cómics y obtenemos las series
    final seriesList = _getUniqueSeries(
      booksProvider.books,
      comicsProvider.comics,
    );

    // Creamos una lista de nombres de series
    final seriesNames = seriesList.map((series) => series.title).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Series'), centerTitle: true),
      body: SeriesFilterAndGrid(
        seriesFuture: Future.value(
          seriesNames,
        ), // Pasamos las series como un Future
      ),
    );
  }

  List<Series> _getUniqueSeries(List<Book> books, List<Comic> comics) {
    final List<Series> allSeries = [];
    final comicsProvider = Provider.of<ComicsProvider>(context);

    // Agregamos los libros
    for (var book in books) {
      allSeries.add(
        Series(
          title: book.series ?? '',
          coverPath: book.coverPath ?? '',
          seriesNumber: book.seriesNumber ?? 0,
        ),
      );
    }

    // Agregamos los cómics
    for (var comic in comicsProvider.comics) {
      allSeries.add(
        Series(
          title: comic.series ?? '',
          coverPath: comic.coverPath ?? '',
          seriesNumber: comic.seriesNumber ?? 0,
        ),
      );
    }

    // Eliminar duplicados basados en el título de la serie
    final Map<String, Series> uniqueSeriesMap = {};
    for (var series in allSeries) {
      if (!uniqueSeriesMap.containsKey(series.title)) {
        uniqueSeriesMap[series.title] = series;
      }
    }

    // Devolver las series únicas como una lista
    return uniqueSeriesMap.values.toList();
  }
}
