import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/models/feed_item.dart';

class FeedsService {
  static final String _baseUrl = '/api/feeds';

  static Future<void> addFeed(Map<String, dynamic> feed) async {
    await ApiService.dio.post(_baseUrl, data: feed);
  }

  static Future<List<Map<String, dynamic>>> getAllFeeds() async {
    final response = await ApiService.dio.get(_baseUrl);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }
    throw Exception('Error al obtener los feeds');
  }

  static Future<void> updateFeed(int id, Map<String, dynamic> feed) async {
    await ApiService.dio.put('$_baseUrl/$id', data: feed);
  }

  static Future<void> deleteFeed(int id) async {
    await ApiService.dio.delete('$_baseUrl/$id');
  }

  static Future<List<FeedItem>> fetchFeedFromUrl(String url) async {
    final response = await ApiService.dio.get(
      '/api/feeds/parse',
      queryParameters: {'url': url},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];

      // Asegurarse de que sea una lista
      if (data is List) {
        return data.map((item) => FeedItem.fromMap(item)).toList();
      }
    }

    throw Exception('Error al cargar el feed');
  }
}
