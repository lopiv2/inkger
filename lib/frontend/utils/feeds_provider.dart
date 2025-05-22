import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/feed.dart';
import 'package:inkger/frontend/models/feed_item.dart';
import 'package:inkger/frontend/services/feeds_service.dart';

class FeedsProvider extends ChangeNotifier {
  final List<Feed> _feeds = [];
  List<Feed> get feeds => List.unmodifiable(_feeds);

  final List<FeedItem> _feedsItems = []; // Todos los items cargados
  List<FeedItem> get feedsItems => List.unmodifiable(_feedsItems);

  int get totalFeeds => _feedsItems.length;

  final List<Map<String, dynamic>> _groupedFeeds = [];
  List<Map<String, dynamic>> get groupedFeedsBySource => _groupedFeeds;

  // Carga todos los feeds de todas las fuentes
  // Carga todos los feeds de todas las fuentes
  Future<void> loadAllFeedsFromSources() async {
    _feedsItems.clear();
    _feeds.clear();
    _groupedFeeds.clear();

    try {
      // 1. Obtener todas las fuentes
      final sources =
          await FeedsService.getAllFeeds(); // List<Map<String, dynamic>>

      // 2. Convertirlas a Feed
      for (var source in sources) {
        _feeds.add(Feed.fromMap(source));
      }

      // 3. Por cada fuente, obtener los items del RSS
      for (var source in _feeds) {
        try {
          if(source.active == false) continue; // Si la fuente no está activa, saltar
          final items = await FeedsService.fetchFeedFromUrl(source.url);

          // Asignar sourceUrl (y opcionalmente sourceName)
          final itemsWithSource = items
              .map(
                (item) => item.copyWith(
                  sourceUrl: source.url,
                  sourceName: source.name,
                ),
              )
              .toList();

          _feedsItems.addAll(itemsWithSource);
        } catch (e) {
          print('Error cargando items de feed ${source.name}: $e');
        }
      }

      // 4. Agrupar por fuente
      for (var source in _feeds) {
        final itemsForSource = _feedsItems
            .where((item) => item.sourceUrl == source.url)
            .toList();

        _groupedFeeds.add({
          'name': source.name,
          'active': source.active,
          'logo': source.logo,
          'url': source.url,
          'new': itemsForSource.length,
          'feeds': itemsForSource,
        });
      }

      notifyListeners();
    } catch (e) {
      print('Error cargando fuentes: $e');
    }
  }

  // Filtrar items por sourceUrl
  List<FeedItem> feedsBySource(String sourceUrl) {
    return _feedsItems.where((item) => item.sourceUrl == sourceUrl).toList();
  }

  // CRUD para fuentes

  void addFeed(Feed feed) {
    _feeds.add(feed);
    notifyListeners();
  }

  void updateFeed(int index, Feed newFeed) {
    if (index >= 0 && index < _feeds.length) {
      _feeds[index] = newFeed;
      notifyListeners();
    }
  }

  void deleteFeed(int index) {
    if (index >= 0 && index < _feeds.length) {
      _feeds.removeAt(index);
      notifyListeners();
    }
  }

  void replaceAll(List<Feed> newFeeds) {
    _feeds
      ..clear()
      ..addAll(newFeeds);
    notifyListeners();
  }
}
