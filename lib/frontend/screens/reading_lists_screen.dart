import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/utils/reading_list_provider.dart';
import 'package:inkger/frontend/widgets/reading_list_filter_grid.dart';
import 'package:provider/provider.dart';

class ReadingListScreen extends StatelessWidget {
  const ReadingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                debugPrint('Crear nueva lista');
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
      body: FutureBuilder(
        future: context.read<ReadingListProvider>().fetchReadingLists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final readingLists = context.watch<ReadingListProvider>().lists;

            // Validar si la lista es nula o está vacía antes de procesarla.
            if (readingLists.isEmpty) {
              return const Center(child: Text('No hay listas de lectura disponibles.'));
            }

            return ReadingListFilterAndGrid(readingLists: readingLists);
          }
        },
      ),
    );
  }
}
