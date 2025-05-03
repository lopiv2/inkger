import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/reading_list_services.dart';
import '../models/reading_list.dart'; // Asegúrate de que la clase ReadingList esté definida correctamente. // Importa el servicio para obtener las listas.

class ReadingListProvider with ChangeNotifier {
  final List<ReadingList> _lists = []; // Lista privada para almacenar las listas de lectura.

  List<ReadingList> get lists => List.unmodifiable(_lists); // Getter para acceder a las listas.

  // Método para obtener las listas de lectura desde la API.
  Future<void> fetchReadingLists() async {
    try {
      final fetchedLists = await ReadingListServices.getReadingLists(); // Llama al servicio para obtener las listas.
      _lists.clear(); // Limpia las listas actuales.
      _lists.addAll(fetchedLists); // Agrega las listas obtenidas.
      notifyListeners(); // Notifica a los oyentes que las listas han cambiado.
    } catch (e) {
      // Manejo de errores (puedes personalizarlo según sea necesario).
      print('Error al obtener las listas de lectura: $e');
    }
  }

  // Método para agregar una nueva lista de lectura.
  void addList(ReadingList list) {
    _lists.add(list); // Añadir la lista a la lista interna.
    notifyListeners(); // Notificar a los oyentes (widgets) que la lista ha cambiado.
  }

  // Método para eliminar una lista de lectura por su ID.
  void removeList(int id) {
    _lists.removeWhere((list) => list.id == id); // Eliminar la lista que coincide con el ID.
    notifyListeners(); // Notificar a los oyentes que la lista ha cambiado.
  }

  // Limpiar todas las listas de lectura.
  void clear() {
    _lists.clear(); // Limpiar todas las listas.
    notifyListeners(); // Notificar a los oyentes que la lista ha cambiado.
  }
}
