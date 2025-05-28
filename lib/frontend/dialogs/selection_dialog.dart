import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/reading_list_services.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
import 'package:inkger/l10n/app_localizations.dart'; // Importar CommonServices

class SelectionDialog extends StatefulWidget {
  final String title;
  final void Function(Map<String, dynamic>)
  onSelected; // Cambiar para devolver un mapa

  const SelectionDialog({
    Key? key,
    required this.title,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<SelectionDialog> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  List<Map<String, dynamic>> libraryItems = [];
  List<Map<String, dynamic>> filteredItems =
      []; // Lista para los elementos filtrados
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLibraryItems();
  }

  Future<void> _fetchLibraryItems() async {
    try {
      final items = await ReadingListServices.getLibraryItems();
      setState(() {
        libraryItems = items;
        filteredItems = items; // Inicialmente, mostrar todos los elementos
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar los elementos de la biblioteca: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = libraryItems
          .where(
            (item) =>
                (item['title'] ?? '').toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                (item['type'] ?? '').toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seleccionar ejemplar para "${widget.title}"'),
          const SizedBox(height: 8),
          TextField(
            onChanged: _filterItems,
            decoration: InputDecoration(
              hintText: '${AppLocalizations.of(context)!.search}...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      content: isLoading
          ? const Center(child: CustomLoader(size: 60.0, color: Colors.blue))
          : filteredItems.isEmpty
          ? const Text('No hay elementos disponibles en la biblioteca.')
          : SizedBox(
              width: double
                  .maxFinite, // Asegura que el GridView ocupe el ancho máximo disponible
              height:
                  MediaQuery.of(context).size.height *
                  0.7, // Limitar la altura del GridView
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8, // Mantener 8 columnas
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio:
                      0.75, // Reducir el valor para hacer las cartas más altas
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        //print(item);
                        widget.onSelected({
                          'id': item['id'] ?? 'Sin id', // Incluir el id
                          'coverPath':
                              item['coverPath'] ??
                              '', // Incluir la ruta de la portada
                          'title':
                              item['title'] ??
                              'Sin nombre', // Incluir el título
                          'type': item['type'] ?? 'Sin tipo', // Incluir el tipo
                          'series': item['series'] ?? 'Sin serie',
                          'seriesNumber':
                              item['seriesNumber']?.toString() ?? '0',
                        }); // Devolver un mapa con los datos seleccionados
                        Navigator.of(context).pop();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: buildCoverImage(item['coverPath'] ?? ''),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Tooltip(
                            message: item['title'] ?? 'Sin nombre',
                            child: Text(
                              item['title'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['series']} #${item['seriesNumber'] ?? '0'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['type'] ?? 'Desconocido',
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }
}
