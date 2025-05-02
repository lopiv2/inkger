import 'package:flutter/material.dart';
import '../models/reading_list.dart'; // Asegúrate de que la clase ReadingList esté definida correctamente.

class ReadingListProvider with ChangeNotifier {
  final List<ReadingList> _lists = []; // Lista privada para almacenar las listas de lectura.

  List<ReadingList> get lists => List.unmodifiable(_lists); // Getter para acceder a las listas.

  // Método para obtener las listas de lectura (simulado con un retraso para simular la llamada a una API o base de datos).
  Future<List<ReadingList>> fetchReadingLists() async {
    await Future.delayed(const Duration(seconds: 2)); // Simula un retraso de 2 segundos.
    return [
      ReadingList(title: 'Lista 1', coverUrl: 'http://example.com/cover1.jpg', items: []),
      ReadingList(title: 'Lista 2', coverUrl: 'http://example.com/cover2.jpg', items: [] ),
    ];
  }

  // Método para agregar una nueva lista de lectura.
  void addList(ReadingList list) {
    _lists.add(list); // Añadir la lista a la lista interna.
    notifyListeners(); // Notificar a los oyentes (widgets) que la lista ha cambiado.
  }

  // Método para eliminar una lista de lectura por su ID.
  /*void removeList(int id) {
    _lists.removeWhere((list) => list.id == id); // Eliminar la lista que coincide con el ID.
    notifyListeners(); // Notificar a los oyentes que la lista ha cambiado.
  }*/

  // Limpiar todas las listas de lectura.
  void clear() {
    _lists.clear(); // Limpiar todas las listas.
    notifyListeners(); // Notificar a los oyentes que la lista ha cambiado.
  }
}
