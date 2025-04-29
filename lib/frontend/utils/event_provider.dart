import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:inkger/frontend/models/event.dart';
import 'package:inkger/frontend/services/events_services.dart';

class EventProvider with ChangeNotifier {
  final Map<DateTime, List<Event>> _events = {};

  Map<DateTime, List<Event>> get events => _events;

  Future<void> loadEvents() async {
    final data = await EventServices.loadEvents(); // 👈 AÑADE await

    _events.clear();

    if (data != null) {
      for (var item in data) {
        final event = Event.fromJson(item);
        final key = DateTime.utc(
          event.date.year,
          event.date.month,
          event.date.day,
        );
        _events.putIfAbsent(key, () => []).add(event);
      }
    }

    notifyListeners();
  }

  void addEvent(Event event) {
    final key = DateTime.utc(event.date.year, event.date.month, event.date.day);
    _events.putIfAbsent(key, () => []).add(event);
    notifyListeners();
  }

  Future<bool> deleteEvent(Event event) async {
    try {
      final dayKey = DateTime.utc(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      if (_events.containsKey(dayKey)) {
        _events[dayKey]!.removeWhere((e) => e.id == event.id);
        notifyListeners();
      }
      await EventServices.deleteEvent(event);
      return true;
    } catch (e) {
      debugPrint('Error en deleteEvent: $e');
      return false;
    }
  }

  Future<bool> updateEvent(Event updatedEvent) async {
    try {
      // Lógica de actualización local
      final dayKey = DateTime.utc(
        updatedEvent.date.year,
        updatedEvent.date.month,
        updatedEvent.date.day,
      );

      if (_events.containsKey(dayKey)) {
        final index = _events[dayKey]!.indexWhere(
          (e) => e.id == updatedEvent.id,
        );
        if (index != -1) {
          _events[dayKey]![index] = updatedEvent;
        } else {
          return false;
        }
      } else {
        return false;
      }
      notifyListeners();
      await EventServices.updateEvent(updatedEvent);
      return true;
    } catch (e) {
      debugPrint('Error en updateEvent: $e');
      return false;
    }
  }

  notifyListeners();

  Future<bool> saveEvent(Event event) async {
    try {
      final response = await EventServices.saveEvent(event);
      final data = response?.data;
      final newEvent = Event.fromJson(data);
      addEvent(newEvent); // <- Usamos el evento ya con ID asignado
      return true;
    } catch (e) {
      debugPrint('Error guardando evento: $e');
      return false;
    }
  }

  List<Event> getEventsForDay(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return _events[key] ?? [];
  }
}
