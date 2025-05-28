import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/compare_metadata_book_dialog.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookSearchDialog extends StatefulWidget {
  final Book book;

  const BookSearchDialog({super.key, required this.book});

  @override
  _BookSearchDialogState createState() => _BookSearchDialogState();
}

class _BookSearchDialogState extends State<BookSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  // Estados de los checkboxes
  bool openLibrary = true;
  bool ibdb = true;
  bool googleBooks = true;

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await BookServices.getBookMetadata(
        query,
        widget.book,
        openLibrary,
        ibdb,
        googleBooks,
      );
      //print('Resultados de búsqueda: $results');
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar libros: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectBook(Map<String, dynamic> newBook) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');

    final provider = Provider.of<BooksProvider>(context, listen: false);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CompareBookDialog(
        currentBook: widget.book.toDisplayMap(),
        newBookData: newBook.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        ),
      ),
    );

    if (result != null) {
      Navigator.pop(context);
      await provider.loadBooks(id ?? 0); // Devolver los datos seleccionados
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buscar libro'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            //Cuadro de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Introduce título o autor',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchBooks(_searchController.text),
                ),
              ),
              onSubmitted: _searchBooks,
            ),
            const SizedBox(height: 16),
            // Fila con 4 checkboxes
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                FilterChip(
                  label: const Text('Open Library'),
                  selected: openLibrary,
                  onSelected: (value) => setState(() => openLibrary = value),
                ),
                FilterChip(
                  label: const Text('IBDB'),
                  selected: ibdb,
                  onSelected: (value) => setState(() => ibdb = value),
                ),
                FilterChip(
                  label: const Text('Google Books'),
                  selected: googleBooks,
                  onSelected: (value) => setState(() => googleBooks = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Expanded(
                    child: Center(child: CustomLoader(size: 60.0, color: Colors.blue)),
                  )
                : _results.isEmpty
                ? const Expanded(child: Center(child: Text('Sin resultados.')))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final book = _results[index];
                        return InkWell(
                          onTap: () => _selectBook(book),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Imagen del libro
                                book['cover'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          book['cover'],
                                          width: 80,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 80,
                                                  height: 120,
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.broken_image,
                                                  ),
                                                );
                                              },
                                        ),
                                      )
                                    : const Icon(Icons.book, size: 80),

                                const SizedBox(width: 12),

                                // Título, autor y descripción
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book['title'] ?? 'Sin título',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book['author'] ?? 'Autor desconocido',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        book['description'] ??
                                            'Sin descripción.',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Fuente: ${book['origin']}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
