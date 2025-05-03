import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/book_details_dialog.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/utils/functions.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/reading_progress_bar.dart';

class HoverableGridItem extends StatefulWidget {
  final dynamic item;
  final bool isBook;

  const HoverableGridItem({required this.item, required this.isBook});

  @override
  HoverableGridItemState createState() => HoverableGridItemState();
}

class HoverableGridItemState extends State<HoverableGridItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        children: [
          // Contenido base de la tarjeta (sin cambios)
          _buildBaseCard(),
          // Overlay siempre presente, pero invisible cuando no hay hover
          if (_isHovered) _buildHoverOverlay(),

          // Botones también con visibilidad controlada
          if (_isHovered) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBaseCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: buildCoverImage(widget.item.coverPath),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isBook
                          ? widget.item.author ?? 'Autor desconocido'
                          : 'Nº ${widget.item.seriesNumber ?? 'N/A'}',
                      style: Theme.of(context).textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                      child: ReadingProgressBarIndicator(
                        value: widget.item.readingProgress?['progress'] ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: widget.isBook
                    ? Colors.blue.withOpacity(0.9)
                    : Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 4),
                  Text(
                    "Nº ${widget.item.seriesNumber.toString()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: widget.isBook
                    ? Colors.blue.withOpacity(0.9)
                    : Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isBook ? Icons.book : Icons.photo_library,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.isBook ? 'Libro' : 'Cómic',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoverOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow, width: 2),
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: IconButton(
            color: Colors.white,
            onPressed: () {
              widget.isBook
                  ? loadBookFile(
                      context,
                      widget.item.id.toString(),
                      widget.item.title,
                      widget.item.readingProgress!['readingProgress'],
                    )
                  : loadComicFile(
                      context,
                      widget.item.id.toString(),
                      widget.item.title,
                      widget.item.readingProgress!['readingProgress'],
                    );
            },
            icon: Icon(widget.isBook ? Icons.menu_book : Icons.photo_library),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _editItem(),
                icon: const Icon(Icons.edit, size: 20, color: Colors.white),
              ),
              IconButton(
                onPressed: () => BookServices.showDeleteConfirmationDialog(
                  context,
                  widget.item,
                ),
                icon: const Icon(Icons.delete, size: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editItem() {
    showBookDetailsDialog(context, widget.item);
  }
}
