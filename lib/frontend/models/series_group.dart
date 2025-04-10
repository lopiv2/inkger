  // Clase auxiliar para agrupar series
  import 'package:inkger/frontend/models/series.dart';

class SeriesGroup {
    final String title;
    final String coverPath;
    final int itemCount;
    final List<Series> items;

    SeriesGroup({
      required this.title,
      required this.coverPath,
      required this.itemCount,
      required this.items,
    });
  }