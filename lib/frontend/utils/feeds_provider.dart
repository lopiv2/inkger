import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/feed.dart';
import 'package:inkger/frontend/services/feeds_service.dart';

class FeedsProvider extends ChangeNotifier {
  int _totalFeeds = 0;
  int get totalFeeds => _totalFeeds;

  final List<Feed> _feeds = [];
  List<Feed> get feeds => List.unmodifiable(_feeds);

  // Cargar feeds desde el servicio
  Future<void> loadFeeds() async {
    try {
      final loadedFeedsData = await FeedsService.getAllFeeds();
      final loadedFeeds = loadedFeedsData
          .map<Feed>((map) => Feed.fromMap(map))
          .toList();
      _feeds.clear();
      _feeds.addAll(loadedFeeds);
      _totalFeeds = _feeds.length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando feeds: $e');
    }
  }

  List<Map<String, dynamic>> get groupedFeedsBySource {
    // Agrupa feeds por 'sourceName' o 'category' (ajusta según tu modelo)
    final groups = groupBy(
      feeds,
      (Feed f) => f.category,
    );

    return groups.entries.map((entry) {
      final sourceName = entry.key;
      final feedsList = entry.value;

      // Aquí deberías obtener el logo de la fuente (puedes elegir el logo del primer feed o manejarlo aparte)
      final logo = feedsList.isNotEmpty ? feedsList.first.logo : '';

      // Cuenta feeds nuevos. Supondré que hay un campo 'isNew' booleano en Feed (ajusta según tu modelo)
      final newCount = feedsList.where((f) => true).length;

      return {
        'name': sourceName,
        'logo': logo,
        'new': newCount,
        'feeds': feedsList
            .map((f) => {'title': '', 'desc': ''})
            .toList(),
      };
    }).toList();
  }

  void setTotalFeeds(int value) {
    _totalFeeds = value;
    notifyListeners();
  }

  void addFeed(Map<String, dynamic> feedData) {
    final feed = Feed.fromMap(feedData);
    _feeds.add(feed);
    _totalFeeds = _feeds.length;
    notifyListeners();
  }

  void updateFeed(int index, Map<String, dynamic> newFeedData) {
    if (index >= 0 && index < _feeds.length) {
      final oldFeed = _feeds[index];
      final updatedFeed = Feed(
        id: oldFeed.id, // mantener el id original
        name: newFeedData['name'] ?? oldFeed.name,
        logo: newFeedData['logo'] ?? oldFeed.logo,
        url: newFeedData['url'] ?? oldFeed.url,
        category: newFeedData['category'] ?? oldFeed.category,
        active: newFeedData['active'] ?? oldFeed.active,
      );
      _feeds[index] = updatedFeed;
      _totalFeeds = _feeds.length;
      notifyListeners();
    }
  }

  void deleteFeed(int index) {
    if (index >= 0 && index < _feeds.length) {
      _feeds.removeAt(index);
      _totalFeeds = _feeds.length;
      notifyListeners();
    }
  }

  void replaceAll(List<Map<String, dynamic>> newFeedsData) {
    _feeds.clear();
    _feeds.addAll(newFeedsData.map((map) => Feed.fromMap(map)));
    _totalFeeds = _feeds.length;
    notifyListeners();
  }
}
