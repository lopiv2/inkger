import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';

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

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await BookServices.getBookMetadata(
        query,
        widget.book,
      );

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

  void _selectBook(Map<String, dynamic> book) {
    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.85; // el ancho de tu AlertDialog
    const minItemWidth = 160;
    final crossAxisCount = (screenWidth / minItemWidth).floor().clamp(1, 5); // de 1 a 5 columnas

    return AlertDialog(
      title: const Text('Buscar libro'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
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
            _isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _results.isEmpty
                    ? const Expanded(
                        child: Center(child: Text('Sin resultados.')),
                      )
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate:
                               SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,  // 2 columnas
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.6, // ajusta para que la tarjeta no quede muy estirada
                          ),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final book = _results[index];
                            return GestureDetector(
                              onTap: () => _selectBook(book),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: book['cover'] != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(
                                                  book['cover'],
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.book,
                                                size: 80,
                                              ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        book['title'] ?? 'Sin título',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book['author'] ?? 'Autor desconocido',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
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
