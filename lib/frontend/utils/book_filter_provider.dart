import 'package:flutter/material.dart';

class BookFilterProvider with ChangeNotifier {
  List<String> _selectedAuthors = [];
  List<String> _selectedPublishers = [];
  List<String> availableAuthors = [];
  List<String> availablePublishers = [];
  bool _isFilterMenuVisible = false;
  bool _isGridView = true;

  bool get isGridView => _isGridView;

  void setGridView(bool value) {
    _isGridView = value;
    notifyListeners();
  }

  // Getters
  List<String> get selectedAuthors => _selectedAuthors;
  List<String> get selectedPublishers => _selectedPublishers;
  bool get isFilterMenuVisible => _isFilterMenuVisible;

  void fillAuthors(authors) {
    availableAuthors = authors;
    notifyListeners();
  }

  void fillPublishers(publishers) {
    availablePublishers = publishers;
    notifyListeners();
  }

  // Métodos para autores
  void toggleAuthor(String author) {
    if (_selectedAuthors.contains(author)) {
      _selectedAuthors.remove(author);
    } else {
      _selectedAuthors.add(author);
    }
    notifyListeners();
  }

  void addAuthor(String author) {
    if (!_selectedAuthors.contains(author)) {
      _selectedAuthors.add(author);
      notifyListeners();
    }
  }

  void removeAuthor(String author) {
    if (_selectedAuthors.contains(author)) {
      _selectedAuthors.remove(author);
      notifyListeners();
    }
  }

  // Métodos para editoriales
  void togglePublisher(String publisher) {
    if (_selectedPublishers.contains(publisher)) {
      _selectedPublishers.remove(publisher);
    } else {
      _selectedPublishers.add(publisher);
    }
    notifyListeners();
  }

  void addPublisher(String publisher) {
    if (!_selectedPublishers.contains(publisher)) {
      _selectedPublishers.add(publisher);
      notifyListeners();
    }
  }

  void removePublisher(String publisher) {
    if (_selectedPublishers.contains(publisher)) {
      _selectedPublishers.remove(publisher);
      notifyListeners();
    }
  }

  // Métodos para controlar la visibilidad del menú
  void showFilterMenu() {
    if (!_isFilterMenuVisible) {
      _isFilterMenuVisible = true;
      notifyListeners();
    }
  }

  void hideFilterMenu() {
    if (_isFilterMenuVisible) {
      _isFilterMenuVisible = false;
      notifyListeners();
    }
  }

  void toggleFilterMenu() {
    _isFilterMenuVisible = !_isFilterMenuVisible;
    notifyListeners();
  }

  // Método para resetear todos los filtros
  void resetFilters() {
    _selectedAuthors.clear();
    _selectedPublishers.clear();
    notifyListeners();
  }
}
