import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/models/reading_list_item.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/hover_grid_item_reading_list.dart';
import 'package:provider/provider.dart';
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
  Future<List<dynamic>> _fetchedItems = Future.value([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComics();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar los datos al volver a la página
    _loadComics();
  }

  Future<void> _loadComics() async {
    final provider = Provider.of<ComicsProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    // Campos requeridos
    final userId = prefs.getInt('id');
    await provider.loadcomics(userId ?? 0);

    // Obtener los cómics cargados
    final comics = provider.comics;

    // Filtrar y obtener la información completa de los elementos
    final matchingItems = widget.items
        .map((item) {
          if (item is ReadingListItem && item.type == 'comic') {
            return comics.firstWhere(
              (comic) => comic.id.toString() == item.itemId,
              orElse: () => Comic.empty(),
            );
          }
          return null;
        })
        .where((element) => element != null)
        .toList();

    // Guardar los elementos coincidentes con toda la información en fetchedItems
    setState(() {
      _fetchedItems = Future.value(matchingItems);
    });
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
