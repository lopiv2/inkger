import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/services/comic_services.dart';

class ComicsProvider extends ChangeNotifier {
  List<Comic> _comics = [];
  bool _isLoading = false;

  List<Comic> get comics => _comics;
  bool get isLoading => _isLoading;

  void addcomic(Comic comic) {
    _comics.add(comic);
    notifyListeners();
  }

  // Método para cargar libros desde la base de datos o la API
  Future<void> loadcomics(int id) async {
    _isLoading = true;
    notifyListeners();
    _comics.clear(); // Limpiar la lista antes de cargar nuevos datos
    try {
      final response = await ComicServices.getAllcomics(id);
      if (response.statusCode == 200) {
        _comics =
            (response.data as List)
                .map((comicData) => Comic.fromJson(comicData))
                .toList();
      } else {
        throw Exception('Error al cargar los comics');
      }
    } catch (e) {
      throw Exception('Error al obtener los comics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeComic(int id) {
    _comics.removeWhere((comic) => comic.id == id);
    notifyListeners();
  }

  void updatecomic(Comic updatedcomic) {
    int index = _comics.indexWhere((comic) => comic.id == updatedcomic.id);
    if (index != -1) {
      _comics[index] = updatedcomic;
      notifyListeners();
    }
  }

  void setcomics(List<Comic> newcomics) {
    _comics = newcomics;
    notifyListeners();
  }
}
