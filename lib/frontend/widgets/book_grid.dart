import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/functions.dart';
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
    Provider.of<BooksProvider>(context, listen: false).loadBooks();
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
            child: Consumer<BooksProvider>(
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
                    mainAxisExtent: _calculateMainAxisExtent(),
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final coverPath = book.coverPath;

                    switch (_selectedViewMode) {
                      case ViewMode.simple:
                        return _buildSimpleMode(context, book, coverPath);
                      case ViewMode.threeD:
                        return _build3DMode(book, coverPath);
                      case ViewMode.librarian:
                        return _buildLibrarianMode(book, coverPath);
                    }
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
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (event) => _hoverNotifier.value = true,
          onExit: (event) => _hoverNotifier.value = false,
          child: ValueListenableBuilder<bool>(
            valueListenable: _hoverNotifier,
            builder: (context, isHovered, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: _calculateItemHeight(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.3,
                          ), // Sombra más pronunciada
                          blurRadius: 8,
                          spreadRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildCoverImage(coverPath),
                          if (isHovered)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.yellow,
                                  width: 4,
                                ),
                                color: Colors.black.withOpacity(
                                  0.4,
                                ), // Oscurece la imagen
                              ),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  color: Colors.white,
                                  iconSize: 40,
                                  onPressed:
                                      () => {
                                        openEpubReader(
                                          context,
                                          book.filePath ?? '',
                                          book.coverPath ?? ''
                                        ),
                                      },
                                ),
                              ),
                            ),
                          // Botón de edición (abajo izquierda)
                          if (isHovered)
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => debugPrint("Editar libro"),
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Menú de 3 puntos (abajo derecha)
                          if (isHovered)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: PopupMenuButton<String>(
                                onSelected:
                                    (value) =>
                                        debugPrint("Seleccionado: $value"),
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        value: "info",
                                        child: Text("Información"),
                                      ),
                                      PopupMenuItem(
                                        value: "delete",
                                        child: Text("Eliminar"),
                                      ),
                                    ],
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.more_vert,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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

  Widget _build3DMode(Book book, String? coverPath) {
    // Resetear bandera al construir el modo 3D
    _colorCalculated = false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<Color>(
          valueListenable: _dominantColorNotifier,
          builder: (context, dominantColor, _) {
            return Tilt(
              shadowConfig: ShadowConfig(
                direction: ShadowDirection.right,
                minIntensity: 0,
                maxIntensity: 1,
              ),
              childLayout: ChildLayout(
                behind: [
                  Positioned(
                    top: 00.0,
                    left: 40.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: dominantColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(),
                      ),
                      width: 250.0,
                      height: _calculateItemHeight(),
                    ),
                  ),
                  Positioned(
                    top: 00.0,
                    left: 36.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(),
                      ),
                      width: 250.0,
                      height: _calculateItemHeight(),
                    ),
                  ),
                  Positioned(
                    top: 00.0,
                    left: 32.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(),
                      ),
                      width: 250.0,
                      height: _calculateItemHeight(),
                    ),
                  ),
                  Positioned(
                    top: 00.0,
                    left: 28.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(),
                      ),
                      width: 250.0,
                      height: _calculateItemHeight(),
                    ),
                  ),
                  Positioned(
                    top: 00.0,
                    left: 25.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(),
                      ),
                      width: 250.0,
                      height: _calculateItemHeight(),
                    ),
                  ),
                ],
              ),
              tiltConfig: TiltConfig(
                angle: 20, // Inclinación máxima
              ),
              child: MouseRegion(
                onEnter: (event) => _hoverNotifier.value = true,
                onExit: (event) => _hoverNotifier.value = false,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _hoverNotifier,
                  builder: (context, isHovered, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: _calculateItemHeight(),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  0.3,
                                ), // Sombra más pronunciada
                                blurRadius: 8,
                                spreadRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildCoverImage(
                                  coverPath,
                                  calculateColor: true,
                                ),
                                if (isHovered)
                                  Container(
                                    color: Colors.black.withOpacity(
                                      0.4,
                                    ), // Oscurece la imagen
                                    child: Center(
                                      child: Icon(
                                        Icons.remove_red_eye,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                // Botón de edición (abajo izquierda)
                                if (isHovered)
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => debugPrint("Editar libro"),
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                // Menú de 3 puntos (abajo derecha)
                                if (isHovered)
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: PopupMenuButton<String>(
                                      onSelected:
                                          (value) => debugPrint(
                                            "Seleccionado: $value",
                                          ),
                                      itemBuilder:
                                          (context) => [
                                            PopupMenuItem(
                                              value: "info",
                                              child: Text("Información"),
                                            ),
                                            PopupMenuItem(
                                              value: "delete",
                                              child: Text("Eliminar"),
                                            ),
                                          ],
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.more_vert,
                                          size: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
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

        return Image.memory(snapshot.data!, fit: BoxFit.cover);
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

  Widget _buildLoadingOrError(AsyncSnapshot<Uint8List?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    return Center(child: Icon(Icons.broken_image, size: 50));
  }

  double _calculateAspectRatio() => 0.6 + (0.1 * (10 - _crossAxisCount));
  double _calculateMainAxisExtent() => 150 + (100 * (10 - _crossAxisCount));
  double _calculateItemHeight() => _calculateMainAxisExtent() * 0.7;
  double _calculateTextSize() => 14 + (2 * (10 - _crossAxisCount));
}
