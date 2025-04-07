import 'package:flutter/material.dart';

class ComicFilterProvider with ChangeNotifier {
  // Filtros seleccionados
  List<String> _selectedCharacters = [];
  List<String> _selectedTeams = [];
  List<String> _selectedLocations = [];
  List<String> _selectedStoryArcs = [];
  List<String> _selectedSeries = [];
  List<String> _selectedPublishers = [];
  List<String> _selectedWriters = [];

  // Opciones disponibles
  List<String> availableCharacters = [];
  List<String> availableTeams = [];
  List<String> availableLocations = [];
  List<String> availableStoryArcs = [];
  List<String> availableSeries = [];
  List<String> availablePublishers = [];
  List<String> availableWriters = [];

  // Estado de la UI
  bool _isFilterMenuVisible = false;
  bool _isGridView = true;

  // Getters
  bool get isGridView => _isGridView;
  bool get isFilterMenuVisible => _isFilterMenuVisible;
  List<String> get selectedCharacters => _selectedCharacters;
  List<String> get selectedTeams => _selectedTeams;
  List<String> get selectedLocations => _selectedLocations;
  List<String> get selectedStoryArcs => _selectedStoryArcs;
  List<String> get selectedSeries => _selectedSeries;
  List<String> get selectedPublishers => _selectedPublishers;
  List<String> get selectedWriters => _selectedWriters;

  // Métodos para controlar la vista (grid/lista)
  void setGridView(bool value) {
    _isGridView = value;
    notifyListeners();
  }

  // Métodos para llenar las opciones disponibles
  void fillCharacters(List<String> characters) {
    availableCharacters = characters..sort();
    notifyListeners();
  }

  void fillTeams(List<String> teams) {
    availableTeams = teams..sort();
    notifyListeners();
  }

  void fillLocations(List<String> locations) {
    availableLocations = locations..sort();
    notifyListeners();
  }

  void fillStoryArcs(List<String> arcs) {
    availableStoryArcs = arcs..sort();
    notifyListeners();
  }

  void fillSeries(List<String> series) {
    availableSeries = series..sort();
    notifyListeners();
  }

  void fillPublishers(List<String> publishers) {
    availablePublishers = publishers..sort();
    notifyListeners();
  }

  void fillWriters(List<String> writers) {
    availableWriters = writers..sort();
    notifyListeners();
  }

  // Métodos para toggle (agregar/remover) filtros
  void toggleCharacter(String character) {
    _selectedCharacters.contains(character)
        ? _selectedCharacters.remove(character)
        : _selectedCharacters.add(character);
    notifyListeners();
  }

  void addCharacter(String character) {
    if (!_selectedCharacters.contains(character)) {
      _selectedCharacters.add(character);
      notifyListeners();
    }
  }

  void toggleTeam(String team) {
    _selectedTeams.contains(team)
        ? _selectedTeams.remove(team)
        : _selectedTeams.add(team);
    notifyListeners();
  }

  void addTeam(String team) {
    if (!_selectedTeams.contains(team)) {
      _selectedTeams.add(team);
      notifyListeners();
    }
  }

  void toggleLocation(String location) {
    _selectedLocations.contains(location)
        ? _selectedLocations.remove(location)
        : _selectedLocations.add(location);
    notifyListeners();
  }

  void addLocation(String location) {
    if (!_selectedLocations.contains(location)) {
      _selectedLocations.add(location);
      notifyListeners();
    }
  }

  void toggleStoryArc(String arc) {
    _selectedStoryArcs.contains(arc)
        ? _selectedStoryArcs.remove(arc)
        : _selectedStoryArcs.add(arc);
    notifyListeners();
  }

  void addStoryArc(String arc) {
    if (!_selectedStoryArcs.contains(arc)) {
      _selectedStoryArcs.add(arc);
      notifyListeners();
    }
  }

  void toggleSeries(String series) {
    _selectedSeries.contains(series)
        ? _selectedSeries.remove(series)
        : _selectedSeries.add(series);
    notifyListeners();
  }

  void addSerie(String series) {
    if (!_selectedSeries.contains(series)) {
      _selectedSeries.add(series);
      notifyListeners();
    }
  }

  void togglePublisher(String publisher) {
    _selectedPublishers.contains(publisher)
        ? _selectedPublishers.remove(publisher)
        : _selectedPublishers.add(publisher);
    notifyListeners();
  }

  void addPublisher(String publisher) {
    if (!_selectedPublishers.contains(publisher)) {
      _selectedPublishers.add(publisher);
      notifyListeners();
    }
  }

  void toggleWriter(String writer) {
    _selectedWriters.contains(writer)
        ? _selectedWriters.remove(writer)
        : _selectedWriters.add(writer);
    notifyListeners();
  }

  void addWriter(String writer) {
    if (!_selectedWriters.contains(writer)) {
      _selectedWriters.add(writer);
      notifyListeners();
    }
  }

  // Métodos para remover filtros específicos
  void removeCharacter(String character) {
    _selectedCharacters.remove(character);
    notifyListeners();
  }

  void removeTeam(String team) {
    _selectedTeams.remove(team);
    notifyListeners();
  }

  void removeLocation(String location) {
    _selectedLocations.remove(location);
    notifyListeners();
  }

  void removeStoryArc(String arc) {
    _selectedStoryArcs.remove(arc);
    notifyListeners();
  }

  void removeSeries(String series) {
    _selectedSeries.remove(series);
    notifyListeners();
  }

  void removePublisher(String publisher) {
    _selectedPublishers.remove(publisher);
    notifyListeners();
  }

  void removeWriter(String writer) {
    _selectedWriters.remove(writer);
    notifyListeners();
  }

  // Control de visibilidad del menú de filtros
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
    _selectedCharacters.clear();
    _selectedTeams.clear();
    _selectedLocations.clear();
    _selectedStoryArcs.clear();
    _selectedSeries.clear();
    _selectedPublishers.clear();
    _selectedWriters.clear();
    notifyListeners();
  }

  // Método para verificar si hay algún filtro activo
  bool get hasActiveFilters {
    return _selectedCharacters.isNotEmpty ||
        _selectedTeams.isNotEmpty ||
        _selectedLocations.isNotEmpty ||
        _selectedStoryArcs.isNotEmpty ||
        _selectedSeries.isNotEmpty ||
        _selectedPublishers.isNotEmpty ||
        _selectedWriters.isNotEmpty;
  }
}