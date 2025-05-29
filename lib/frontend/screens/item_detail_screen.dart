import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/add_to_reading_list_dialog.dart';
import 'package:inkger/frontend/dialogs/book_details_dialog.dart';
import 'package:inkger/frontend/dialogs/comic_details_dialog.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/utils/functions.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemDetailScreen extends StatefulWidget {
  final dynamic item; // Book o Comic
  final String type;

  const ItemDetailScreen({super.key, required this.item, required this.type});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Casteamos según el tipo
    final book = widget.type == 'book' ? widget.item as Book : null;
    final comic = widget.type == 'comic' ? widget.item as Comic : null;

    final id = book?.id ?? comic?.id ?? 0;
    final title = book?.title ?? comic?.title ?? 'Sin título';
    final author = book?.author ?? comic?.writer ?? 'Desconocido';
    final description = book?.description ?? comic?.description ?? '';
    final coverImage = book?.coverPath ?? comic?.coverPath ?? '';
    final filePath = book?.filePath ?? comic?.filePath ?? '';
    final publicationDate = formatDate(
      book?.publicationDate ?? comic?.publicationDate,
    );
    final publisher = book?.publisher ?? comic?.publisher ?? '';
    final language = book?.language ?? comic?.language ?? '';
    final serie = book?.series ?? comic?.series ?? '';
    final readingProgress =
        book?.readingProgress ?? comic?.readingProgress ?? <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar',
            onPressed: () async {
              widget.type == "book"
                  ? BookServices.showDeleteConfirmationDialog(context, book!)
                  : ComicServices.showDeleteConfirmationDialog(context, comic!);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar metadatos',
            onPressed: () async {
              widget.type == "book"
                  ? showBookDetailsDialog(context, book!)
                  : showComicDetailsDialog(context, comic!);
            },
          ),
          widget.type == "book"
              ? IconButton(
                  icon: Icon(
                    book!.readingProgress!['read']
                        ? Icons.check_circle
                        : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  tooltip: book.readingProgress!['read']
                      ? 'Marcar como no leído'
                      : 'Marcar como leído',
                  onPressed: () async {
                    setState(() {
                      book.readingProgress!['read'] =
                          !book.readingProgress!['read'];
                    });
                    final prefs = await SharedPreferences.getInstance();
                    final id = prefs.getInt('id');
                    final provider = Provider.of<BooksProvider>(
                      context,
                      listen: false,
                    );
                    await provider.loadBooks(id ?? 0);
                    await BookServices.saveReadState(
                      book.id,
                      book.readingProgress!['read'],
                      context,
                    );
                  },
                )
              : IconButton(
                  icon: Icon(
                    comic!.readingProgress!['read']
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  tooltip: comic.readingProgress!['read']
                      ? 'Marcar como no leído'
                      : 'Marcar como leído',
                  onPressed: () async {
                    setState(() {
                      comic.readingProgress!['read'] =
                          !comic.readingProgress!['read'];
                    });
                    final provider = Provider.of<ComicsProvider>(
                      context,
                      listen: false,
                    );
                    final prefs = await SharedPreferences.getInstance();
                    final id = prefs.getInt('id');
                    await ComicServices.saveReadState(
                      comic.id,
                      comic.readingProgress!['read'],
                      context,
                    );
                    await provider.loadcomics(id ?? 0);
                  },
                ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Descargar',
            onPressed: () async {
              if (widget.type == "book") {
                final filePath = book!.filePath;
                String extension = '';
                if (filePath != null && filePath.contains('.')) {
                  extension = filePath.substring(filePath.lastIndexOf('.') + 1);
                }
                await CommonServices.downloadFile(
                  book.id,
                  book.title,
                  extension,
                  "book",
                );
              } else {
                final filePath = comic!.filePath;
                String extension = '';
                if (filePath != null && filePath.contains('.')) {
                  extension = filePath.substring(filePath.lastIndexOf('.') + 1);
                }
                await CommonServices.downloadFile(
                  comic.id,
                  comic.title,
                  extension,
                  "comic",
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Agregar a lista de lectura',
            onPressed: () async {
              widget.type == "book"
                  ? showDialog(
                      context: context,
                      builder: (BuildContext context) => AddToReadingListDialog(
                        id: book!.id,
                        type: 'book',
                        series: book.series,
                        title: book.title,
                      ),
                    )
                  : showDialog(
                      context: context,
                      builder: (BuildContext context) => AddToReadingListDialog(
                        id: comic!.id,
                        type: 'comic',
                        series: comic.series,
                        title: comic.title,
                      ),
                    );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildCoverImage(width: 300, height: 500, coverImage),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      Expanded(
                        child: _buildInfo(
                          context,
                          title,
                          author,
                          description,
                          publicationDate,
                          publisher,
                          language,
                          serie,
                          () => _checkReader(
                            context,
                            widget.type,
                            filePath,
                            id,
                            title,
                            readingProgress,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      buildCoverImage(width: 200, height: 400, coverImage),
                      const SizedBox(height: 16),
                      _buildInfo(
                        context,
                        title,
                        author,
                        description,
                        publicationDate,
                        publisher,
                        language,
                        serie,
                        () => _checkReader(
                          context,
                          widget.type,
                          filePath,
                          id,
                          title,
                          readingProgress,
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildInfo(
    BuildContext context,
    String title,
    String author,
    String description,
    String publicationDate,
    String publisher,
    String language,
    String serie,
    VoidCallback onReadPressed,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Table(
          columnWidths: {
            0: FixedColumnWidth(MediaQuery.of(context).size.width * 0.1),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            TableRow(children: [const Text("Autor(es)"), Text(author)]),
            TableRow(children: [const Text("Editor"), Text(publisher)]),
            TableRow(
              children: [const Text("Publicado"), Text(publicationDate)],
            ),
            TableRow(children: [const Text("Idioma"), Text(language)]),
            TableRow(children: [const Text("Serie"), Text(serie)]),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Text(description, textAlign: TextAlign.justify),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onReadPressed,
          icon: const Icon(Icons.menu_book),
          label: const Text('Leer'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  void _checkReader(
    BuildContext context,
    String type,
    String filePath,
    int id,
    String title,
    Map<String, dynamic> readingProgress,
  ) {
    if (type == 'book') {
      final extension = filePath.split('.').last.toLowerCase();
      if (extension == 'epub') {
        loadBookFile(
          context,
          id.toString(),
          title,
          readingProgress['readingProgress'],
        );
      } else if (extension == 'mobi') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Visualización no soportada'),
            content: const Text(
              'Solo se pueden visualizar archivos EPUB. Por favor, convierte el archivo antes de visualizarlo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } else {
      loadComicFile(
        context,
        id.toString(),
        title,
        readingProgress['readingProgress'],
        '',
      );
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    final formatter = DateFormat('d MMM yyyy', 'es');
    return formatter.format(date);
  }
}
