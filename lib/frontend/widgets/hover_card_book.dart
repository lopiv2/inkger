import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/book_details_dialog.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/utils/functions.dart';

class HoverCardBook extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDelete; // Callback para la eliminación
  final Book book;

  const HoverCardBook({
    super.key,
    required this.child,
    this.onDelete,
    required this.book,
  });

  @override
  // ignore: library_private_types_in_public_api
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCardBook> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        children: [
          widget.child,
          if (_isHovered)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellow, width: 4),
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Center(
                  child: Tooltip(
                    message: "Abrir lector",
                    child: IconButton(
                      onPressed: () {
                        loadBookFile(
                          context,
                          widget.book.id.toString(),
                          widget.book.title,
                          widget.book.readingProgress!['readingProgress'],
                        );
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
                onSelected: (value) => debugPrint("Seleccionado: $value"),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(value: "info", child: Text("Información")),
                      PopupMenuItem(
                        value: "delete",
                        child: Text("Eliminar"),
                        onTap: () => widget.onDelete?.call(),
                      ),
                    ],
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
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
