import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/functions.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/frontend/widgets/hover_card_book.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

enum ViewMode { simple, threeD, librarian }

class BooksGrid extends StatefulWidget {
  @override
  State<BooksGrid> createState() => _BooksGridState();
}

class _BooksGridState extends State<BooksGrid> {
  double _crossAxisCount = 5;
  final double _minCrossAxisCount = 5;
  final double _maxCrossAxisCount = 10;
  ViewMode _selectedViewMode = ViewMode.simple;
  final ValueNotifier<bool> _hoverNotifier = ValueNotifier(false);
  final ValueNotifier<Color> _dominantColorNotifier = ValueNotifier<Color>(
    Colors.grey,
  ); // Color por defecto
  late Future<Color> _dominantColorFuture;
  bool _colorCalculated = false;

  @override
  void dispose() {
    _dominantColorNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Usar WidgetsBinding para posponer la carga después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBooks();
    });
  }

  Future<void> _loadBooks() async {
    final provider = Provider.of<BooksProvider>(context, listen: false);
    await provider.loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(icon: Icon(Icons.menu), onPressed: () {}),
                IconButton(icon: Icon(Icons.search), onPressed: () {}),
                IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Modo:", style: TextStyle(fontSize: 14)),
                  Radio<ViewMode>(
                    value: ViewMode.simple,
                    groupValue: _selectedViewMode,
                    onChanged:
                        (value) => setState(() => _selectedViewMode = value!),
                  ),
                  Text(
                    "Simple",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Radio<ViewMode>(
                    value: ViewMode.threeD,
                    groupValue: _selectedViewMode,
                    onChanged:
                        (value) => setState(() => _selectedViewMode = value!),
                  ),
                  Text(
                    "3D",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Radio<ViewMode>(
                    value: ViewMode.librarian,
                    groupValue: _selectedViewMode,
                    onChanged:
                        (value) => setState(() => _selectedViewMode = value!),
                  ),
                  Text(
                    "Bibliotecario",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Slider(
              value: _crossAxisCount,
              min: _minCrossAxisCount,
              max: _maxCrossAxisCount,
              divisions: (_maxCrossAxisCount - _minCrossAxisCount).toInt(),
              label: _crossAxisCount.round().toString(),
              onChanged: (value) => setState(() => _crossAxisCount = value),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Libros",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxHeight = constraints.maxHeight;
                double itemHeight = _calculateMainAxisExtent();

                // Si el itemHeight es mayor que el espacio disponible, limitarlo
                if (itemHeight * (_crossAxisCount / 2) > maxHeight) {
                  itemHeight = maxHeight / (_crossAxisCount / 5);
                }
                return Consumer<BooksProvider>(
                  builder: (context, booksProvider, child) {
                    final books = booksProvider.books;
                    if (books.isEmpty)
                      return Center(child: Text("No hay libros disponibles"));

                    return GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _crossAxisCount.round(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: _calculateAspectRatio(),
                        mainAxisExtent: itemHeight,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        final coverPath = book.coverPath;

                        switch (_selectedViewMode) {
                          case ViewMode.simple:
                            return _buildSimpleMode(context, book, coverPath);
                          case ViewMode.threeD:
                            return _build3DMode(
                              context,
                              book,
                              coverPath,
                              itemHeight,
                            );
                          case ViewMode.librarian:
                            return _buildLibrarianMode(book, coverPath);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMode(BuildContext context, Book book, String? coverPath) {
    return Column(
      children: [
        HoverCard(
          bookId: book.id,
          onDelete: () => showDeleteConfirmationDialog(context, book),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: _buildCoverImage(coverPath),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          book.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _calculateTextSize(),
          ),
        ),
      ],
    );
  }

  Widget _build3DMode(
    BuildContext context,
    Book book,
    String? coverPath,
    double itemHeight,
  ) {
    return Column(
      children: [
        Tilt(
          tiltConfig: TiltConfig(
            angle: 20, // Inclinación máxima
          ),
          childLayout: ChildLayout(
            behind: [
              Positioned(
                bottom: -10,
                top: 00.0,
                left: 10.0,
                child: TiltParallax(
                  size: const Offset(-50, -50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(),
                    ),
                    width: itemHeight / 2.5,
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                top: 00.0,
                left: 10.0,
                child: TiltParallax(
                  size: const Offset(-25, -25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(),
                    ),
                    width: itemHeight / 2.5,
                  ),
                ),
              ),
            ],
          ),
          child: HoverCard(
            bookId: book.id,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: _buildCoverImage(coverPath),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          book.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _calculateTextSize(),
          ),
        ),
      ],
    );
  }

  Widget _buildLibrarianMode(Book book, String? coverPath) {
    return Container(
      height: _calculateItemHeight(),
      child: Card(
        elevation: 4,
        color: Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildCoverImage(coverPath),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _calculateTextSize() * 0.9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Autor: ${book.author ?? 'Desconocido'}",
                      style: TextStyle(fontSize: _calculateTextSize() * 0.7),
                    ),
                    Text(
                      "ID: ${book.id ?? 'N/A'}",
                      style: TextStyle(fontSize: _calculateTextSize() * 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(String? coverPath, {bool calculateColor = false}) {
    return FutureBuilder<Uint8List?>(
      future: coverPath != null ? BookServices.getBookCover(coverPath) : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Icon(Icons.broken_image, size: 50));
        }

        // Cálculo del color solo cuando hay datos y es necesario
        if (calculateColor && !_colorCalculated && snapshot.hasData) {
          _calculateDominantColor(snapshot.data!);
          _colorCalculated = true;
        }

        return FittedBox(
          fit: BoxFit.contain,
          child: Image.memory(snapshot.data!, fit: BoxFit.contain),
        );
      },
    );
  }

  Future<void> _calculateDominantColor(Uint8List imageBytes) async {
    try {
      final color = await getDominantColor(imageBytes);
      if (mounted) {
        _dominantColorNotifier.value = color;
      }
    } catch (e) {
      debugPrint('Error calculando color: $e');
    }
  }

  Future<void> showDeleteConfirmationDialog(
    BuildContext context,
    Book book,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe tocar un botón para cerrar
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '¿Estás seguro de que quieres eliminar el libro "${book.title}"?',
                ),
                const SizedBox(height: 8),
                const Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el diálogo primero
                try {
                  await BookServices.deleteBook(context, book);
                  // Opcional: Mostrar mensaje de éxito
                  CustomSnackBar.show(
                    context,
                    '"${book.title}" eliminado correctamente',
                    Colors.green,
                    duration: Duration(seconds: 4),
                  );
                } catch (e) {
                  CustomSnackBar.show(
                    context,
                    'Error al eliminar: ${e.toString()}',
                    Colors.red,
                    duration: Duration(seconds: 4),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  double _calculateAspectRatio() => 0.6 + (0.1 * (10 - _crossAxisCount));
  double _calculateMainAxisExtent() => 150 + (100 * (10 - _crossAxisCount));
  double _calculateItemHeight() => _calculateMainAxisExtent() * 0.7;
  double _calculateTextSize() => 14 + (2 * (10 - _crossAxisCount));
}
