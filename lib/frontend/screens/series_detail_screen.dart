import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/hover_grid_item_series.dart';
import 'package:provider/provider.dart';

class SeriesDetailScreen extends StatefulWidget {
  final String seriesTitle;
  final String coverPath;

  const SeriesDetailScreen({
    Key? key,
    required this.seriesTitle,
    required this.coverPath,
  }) : super(key: key);

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context);
    final comicsProvider = Provider.of<ComicsProvider>(context);

    final seriesBooks =
        booksProvider.books
            .where((book) => book.series == widget.seriesTitle)
            .toList();
    final seriesComics =
        comicsProvider.comics
            .where((comic) => comic.series == widget.seriesTitle)
            .toList();
    final allItems = [...seriesBooks, ...seriesComics];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seriesTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Portada de la serie
          _buildSeriesHeader(widget.coverPath),
          // Contadores
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCounterBadge(context, 'Libros', seriesBooks.length),
                _buildCounterBadge(context, 'Cómics', seriesComics.length),
                _buildCounterBadge(context, 'Total', allItems.length),
              ],
            ),
          ),
          // GridView con todos los elementos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 6 : 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7, // Relación de aspecto ajustada
                ),
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  final item = allItems[index];
                  final isBook=item is Book;
                  return HoverableGridItem(item: item, isBook: isBook,);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesHeader(String coverPath) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          Positioned.fill(child: buildCoverImage(coverPath)),
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
              widget.seriesTitle,
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
