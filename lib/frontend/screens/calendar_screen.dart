import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/models/event.dart';
import 'package:inkger/frontend/utils/event_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.loadEvents();
    });
  }

  // Función para obtener eventos de un día específico
  List<String> _getEventsForDay(DateTime day) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    return eventProvider.getEventsForDay(day).map((e) => e.title).toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    _selectedDay ??= _focusedDay;
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de Eventos')),
      body: Column(
        children: [
          TableCalendar<String>(
            rowHeight: 80,
            locale: 'es',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(day);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, isToday: true);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, isSelected: true);
              },
            ),
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              isTodayHighlighted: true,
              markerSizeScale: 0.2,
              markersAlignment: Alignment.bottomCenter,
            ),
          ),

          const SizedBox(height: 8),
          Expanded(
            child:
                _selectedDay != null &&
                    eventProvider.getEventsForDay(_selectedDay!).isNotEmpty
                ? ListView(
                    children: eventProvider
                        .getEventsForDay(_selectedDay!)
                        .map(
                          (event) => MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => _showEventDialog(context, event),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (event.description != null)
                                            Text(
                                              event.description!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  )
                : const Center(child: Text('No hay eventos para este día.')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_selectedDay != null) {
            final result = await showDialog<Map<String, String>>(
              context: context,
              builder: (context) {
                final controller = TextEditingController();
                final controllerDesc = TextEditingController();
                return AlertDialog(
                  title: const Text('Nuevo Evento'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Nombre del evento',
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: controllerDesc,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Descripción del evento',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        final desc = controllerDesc.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.pop(context, {
                            'title': text,
                            'description': desc,
                          });
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                );
              },
            );

            if (result != null &&
                result['title'] != null &&
                result['title']!.isNotEmpty) {
              final day = DateTime.utc(
                _selectedDay!.year,
                _selectedDay!.month,
                _selectedDay!.day,
              );

              final event = Event(
                date: day,
                title: result['title']!,
                description: result['description'],
              );

              if (await eventProvider.saveEvent(event)) {
                CustomSnackBar.show(
                  context,
                  'Evento guardado correctamente',
                  Colors.green,
                  duration: const Duration(seconds: 4),
                );
              }
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEventDialog(BuildContext context, Event event) {
    final controller = TextEditingController(text: event.title);
    final controllerDesc = TextEditingController(text: event.description);
    print(event.id);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalles del Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Título del evento',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controllerDesc,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del evento',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedTitle = controller.text.trim();
                final updatedDesc = controllerDesc.text.trim();

                if (updatedTitle.isNotEmpty &&
                    (updatedTitle != event.title ||
                        updatedDesc != event.description)) {
                  final updatedEvent = event.copyWith(
                    title: updatedTitle,
                    description: updatedDesc,
                  );
                  final provider = Provider.of<EventProvider>(
                    context,
                    listen: false,
                  );

                  final success = await provider.updateEvent(updatedEvent);

                  if (success) {
                    CustomSnackBar.show(
                      context,
                      'Evento actualizado correctamente',
                      Colors.green,
                      duration: const Duration(seconds: 3),
                    );
                  } else {
                    CustomSnackBar.show(
                      context,
                      'Error al actualizar el evento',
                      Colors.red,
                      duration: const Duration(seconds: 3),
                    );
                  }
                }

                Navigator.pop(context);
              },
              child: const Text('Guardar cambios'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar evento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar evento'),
                    content: const Text(
                      '¿Estás seguro de que quieres eliminar este evento?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sí'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final provider = Provider.of<EventProvider>(
                    context,
                    listen: false,
                  );
                  final success = await provider.deleteEvent(event);
                  context.pop(); // Cierra el diálogo principal

                  if (success) {
                    CustomSnackBar.show(
                      context,
                      'Evento eliminado',
                      Colors.green,
                      duration: const Duration(seconds: 3),
                    );
                  } else {
                    CustomSnackBar.show(
                      context,
                      'Error al eliminar el evento',
                      Colors.red,
                      duration: const Duration(seconds: 3),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue
            : isToday
            ? Colors.blue.shade100
            : Colors.transparent,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
