import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/services/reading_list_services.dart';
import 'package:inkger/frontend/utils/functions.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/frontend/widgets/reading_progress_bar.dart';

class HoverableGridItemReadingList extends StatefulWidget {
  final dynamic item;
  final Function(dynamic item)? onDelete;

  const HoverableGridItemReadingList({
    Key? key,
    required this.item,
    this.onDelete,
  }) : super(key: key);

  @override
  HoverableGridItemReadingListState createState() =>
      HoverableGridItemReadingListState();
}

class HoverableGridItemReadingListState
    extends State<HoverableGridItemReadingList> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        children: [
          // Contenido base de la tarjeta
          _buildBaseCard(),
          // Overlay visible al hacer hover
          if (_isHovered) _buildHoverOverlay(),
          // Botones de acción visibles al hacer hover
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
                  child: buildCoverImage(widget.item.coverPath ?? ''),
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
                    Text(
                      '${widget.item.series} #${widget.item.seriesNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                      child: ReadingProgressBarIndicator(
                        value:
                            widget.item.readingProgress?['readingProgress'] ??
                            0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
              if (widget.item is Book) {
                loadBookFile(
                  context,
                  widget.item.id.toString(),
                  widget.item.title,
                  widget.item.readingProgress!['readingProgress'],
                );
              } else if (widget.item is Comic) {
                loadComicFile(
                  context,
                  widget.item.id.toString(),
                  widget.item.title,
                  widget.item.readingProgress!['readingProgress'],
                  '/reading-lists/',
                );
              }
            },
            icon: const Icon(Icons.menu_book),
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
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: const Text(
                        '¿Estás seguro de que deseas eliminar este elemento?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _deleteItemFromList(
                      widget.item is Comic ? "comic" : "book",
                    );
                    if (widget.onDelete != null) {
                      widget.onDelete!(widget.item);
                    }
                  }
                },
                icon: const Icon(Icons.delete, size: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editItem() {
    //showReadingListItemDetailsDialog(context, widget.item);
  }

  Future<void> _deleteItemFromList(String type) async {
    try {
      await ReadingListServices.deleteItem(widget.item.id, type);
      CustomSnackBar.show(
        context,
        'Elemento eliminado de la lista',
        Colors.green,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      CustomSnackBar.show(
        duration: Duration(seconds: 4),
        context,
        'Error al eliminar el elemento: $e',
        Colors.red,
      );
    }
  }
}
