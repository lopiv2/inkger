import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/utils/reading_list_provider.dart';
import 'package:inkger/frontend/widgets/reading_list_filter_grid.dart';
import 'package:provider/provider.dart';

class ReadingListScreen extends StatelessWidget {
  const ReadingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener las listas de lectura de un provider o de cualquier fuente de datos
    final readingListsFuture = context
        .watch<ReadingListProvider>()
        .fetchReadingLists();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Listas de Lectura'),
        actions: [
          // Botón para crear una nueva lista
          Tooltip(
            message: "Crear lista",
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Aquí puedes agregar la lógica para crear una nueva lista.
                // Por ejemplo, navegar a una nueva pantalla para crear una lista.
                print('Crear nueva lista');
              },
            ),
          ),
          // Botón para importar una lista
          Tooltip(
            message: "Importar lista",
            child: IconButton(
              icon: const Icon(Icons.import_export),
              onPressed: () {
                context.push("/reading-lists/import-list");
              },
            ),
          ),
        ],
      ),
      body: ReadingListFilterAndGrid(readingListsFuture: readingListsFuture),
    );
  }
}
