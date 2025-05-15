import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/book_details_dialog.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/utils/functions.dart';

class HoverCardBook extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDelete; // Callback para la eliminación
  final VoidCallback? onConvert; // Callback para la conversion de archivos
  final VoidCallback? onAddToList; // Callback para la conversion de archivos
  final Book book;

  const HoverCardBook({
    super.key,
    required this.child,
    this.onDelete,
    this.onConvert,
    this.onAddToList,
    required this.book,
  });

  @override
  // ignore: library_private_types_in_public_api
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCardBook> {
  bool _isHovered = false;
  bool _menuOpen = false;

  void _setHovered(bool value) {
    if (!_menuOpen) {
      setState(() => _isHovered = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Stack(
        children: [
          widget.child,
          if (_isHovered)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellow, width: 4),
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Center(
                  child: Tooltip(
                    message: "Abrir lector",
                    child: IconButton(
                      onPressed: () {
                        final extension = widget.book.filePath?.split('.').last.toLowerCase();
                        if (extension == 'epub') {
                          loadBookFile(
                            context,
                            widget.book.id.toString(),
                            widget.book.title,
                            widget.book.readingProgress!['readingProgress'],
                          );
                        } else if (extension == 'mobi') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Visualización no soportada'),
                              content: const Text('Solo se pueden visualizar archivos EPUB. Por favor, convierte el archivo antes de visualizarlo.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      splashColor: Colors.white,
                      icon: Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Botón de edición (abajo izquierda)
          if (_isHovered)
            Positioned(
              bottom: 20,
              left: 8,
              child: IconButton(
                onPressed: () {
                  showBookDetailsDialog(context, widget.book);
                },
                color: Colors.white,
                splashColor: Colors.white,
                icon: Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          // Menú de 3 puntos (abajo derecha)
          if (_isHovered)
            Positioned(
              bottom: 20,
              right: 8,
              child: PopupMenuButton<String>(
                offset: Offset(0, 30),
                onSelected: (value) {
                  setState(() => _menuOpen = false);
                  if (value == "convert") {
                    widget.onConvert?.call();
                  } else if (value == "add") {
                    widget.onAddToList?.call();
                  } else if (value == "delete") {
                    widget.onDelete?.call();
                  }
                },
                onCanceled: () {
                  setState(() => _menuOpen = false);
                },
                onOpened: () {
                  setState(() => _menuOpen = true);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "convert",
                    child: Text("Convertir a..."),
                  ),
                  PopupMenuItem(
                    value: "add",
                    child: Text("Añadir a lista..."),
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
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Icon(Icons.more_vert, size: 18, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
