import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/dialogs/comic_details_dialog.dart';
import 'package:inkger/frontend/models/comic.dart';

class HoverCardComic extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDelete; // Callback para la eliminación
  final VoidCallback?
  onSearchMetadata; // Callback para la busqueda de metadatos
  final VoidCallback? onConvert; // Callback para la conversion de archivos
  final VoidCallback? onAddToList; // Callback para la conversion de archivos
  final VoidCallback? onDownload; // Callback para la conversion de archivos
  final Comic comic;

  const HoverCardComic({
    super.key,
    required this.child,
    this.onDelete,
    this.onDownload,
    this.onSearchMetadata,
    this.onConvert,
    this.onAddToList,
    required this.comic,
  });

  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCardComic> {
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
                  child: Tooltip(
                    message: "Abrir comic",
                    child: IconButton(
                      onPressed: () {
                        context.push(
                          '/item-details/comic/${widget.comic.id}',
                          extra: widget.comic.toJson(),
                        );
                      },
                      splashColor: Colors.white,
                      icon: Icon(Icons.pageview, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ),
            ),
          // Botón de edición (abajo izquierda)
          if (_isHovered)
            Positioned(
              bottom: 15,
              left: 8,
              child: IconButton(
                onPressed: () {
                  showComicDetailsDialog(context, widget.comic);
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
                onSelected: (value) => debugPrint("Seleccionado: $value"),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "convert",
                    child: Text("Convertir a..."),
                    onTap: () => widget.onConvert?.call(),
                  ),
                  PopupMenuItem(
                    value: "add",
                    child: Text("Añadir a lista..."),
                    onTap: () => widget.onAddToList?.call(),
                  ),
                  PopupMenuItem(
                    value: "metadata",
                    child: Text("Obtener metadatos"),
                    onTap: () => widget.onSearchMetadata?.call(),
                  ),
                  PopupMenuItem(
                    value: "delete",
                    child: Text("Eliminar"),
                    onTap: () => widget.onDelete?.call(),
                  ),
                  PopupMenuItem(
                    value: "download",
                    child: Text("Descargar archivo"),
                    onTap: ()=> widget.onDownload?.call(),
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
