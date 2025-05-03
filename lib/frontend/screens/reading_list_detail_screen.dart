import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/models/reading_list_item.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/hover_grid_item_reading_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingListDetailScreen extends StatefulWidget {
  final String title;
  final String? coverUrl;
  final List<dynamic> items; // Lista de IDs de los elementos
  final int count; // Cantidad de elementos

  const ReadingListDetailScreen({
    Key? key,
    required this.title,
    this.coverUrl,
    required this.items,
    required this.count,
  }) : super(key: key);

  @override
  State<ReadingListDetailScreen> createState() =>
      _ReadingListDetailScreenState();
}

class _ReadingListDetailScreenState extends State<ReadingListDetailScreen> {
  late Future<List<dynamic>> _fetchedItems;

  @override
  void initState() {
    super.initState();
    _fetchedItems = _fetchItems(widget.items);
  }

  Future<List<dynamic>> _fetchItems(List<dynamic> items) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    List<dynamic> fetchedItems = [];
    for (var item in items) {
      try {
        // Asegúrate de que item tenga las propiedades necesarias
        if (item is ReadingListItem) {
          final type = item.type; // Cambia esto según la propiedad real
          final id = int.tryParse(item.itemId) ?? 0;

          if (type == 'book') {
            final book = await BookServices.fetchBookById(id, userId!);
            fetchedItems.add(book);
          } else if (type == 'comic') {
            final comic = await ComicServices.fetchComicById(id, userId!);
            fetchedItems.add(comic);
          } else {
            debugPrint('Tipo desconocido: $type');
          }
        } else {
          debugPrint('Error: item no es de tipo ReadingListItem');
        }
      } catch (e) {
        debugPrint('Error procesando el item: $item, Error: $e');
      }
    }
    return fetchedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Portada de la lista de lectura
          if (widget.coverUrl != null) _buildListHeader(widget.coverUrl!),
          // Contador
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: _buildCounterBadge(context, 'Total', widget.count),
          ),
          // GridView con todos los elementos
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchedItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar los datos'));
                } else {
                  final items = snapshot.data ?? [];
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600
                            ? 6
                            : 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return HoverableGridItemReadingList(item: item);
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(String coverUrl) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          Positioned.fill(child: buildCoverImage(coverUrl)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBadge(BuildContext context, String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
