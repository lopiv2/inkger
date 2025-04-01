import 'package:flutter/material.dart';
import 'package:inkger/frontend/utils/functions.dart';

class HoverCard extends StatefulWidget {
  final Widget child;
  final int bookId; // Agregamos el id del libro
  final String title; // Agregamos el id del libro
  final VoidCallback? onDelete; // Callback para la eliminación

  const HoverCard({
    super.key,
    required this.child,
    required this.bookId,
    this.onDelete,
    required this.title,
  });

  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
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
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      loadBookFile(context, widget.bookId.toString(), widget.title);
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          // Botón de edición (abajo izquierda)
          if (_isHovered)
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
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Icon(Icons.edit, size: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
          // Menú de 3 puntos (abajo derecha)
          if (_isHovered)
            Positioned(
              bottom: 8,
              right: 8,
              child: PopupMenuButton<String>(
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
