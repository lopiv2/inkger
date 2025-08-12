import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/widgets/editable_table_cell.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';

class ComicsEditableTable extends StatefulWidget {
  final List<Comic> comics;
  final List<Comic> selectedComics;
  final Function(Comic, bool) onSelectComic;
  final Function() onBatchEdit;
  final Map<int, String?> editingField;
  final Map<int, String> editingValue;
  final Function(int, String) onEditChange;
  final Function(int, String) onEditStart;
  final Function(int) onEditComplete;

  const ComicsEditableTable({
    Key? key,
    required this.comics,
    required this.selectedComics,
    required this.onSelectComic,
    required this.onBatchEdit,
    required this.editingField,
    required this.editingValue,
    required this.onEditChange,
    required this.onEditStart,
    required this.onEditComplete,
  }) : super(key: key);

  @override
  State<ComicsEditableTable> createState() => _ComicsEditableTableState();
}

class _ComicsEditableTableState extends State<ComicsEditableTable> {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      showCheckboxColumn: true,
      columns: const [
        DataColumn(label: Text('Título')),
        DataColumn(label: Text('Autor')),
        DataColumn(label: Text('Serie')),
        DataColumn(label: Text('Leído')),
        DataColumn(label: Text('Editar')),
      ],
      rows: widget.comics.map((comic) {
        final isSelected = widget.selectedComics.contains(comic);
        final isEditing = widget.editingField[comic.id] != null;
        return DataRow(
          selected: isSelected && !isEditing,
          color: MaterialStateProperty.resolveWith<Color?>((states) {
            if (isEditing) return Colors.transparent;
            return null;
          }),
          onSelectChanged: (selected) {
            widget.onSelectComic(comic, selected ?? false);
          },
          cells: [
            DataCell(EditableTableCell(
              value: widget.editingField[comic.id] == 'title' ? (widget.editingValue[comic.id] ?? '') : comic.title,
              isEditing: widget.editingField[comic.id] == 'title',
              onChanged: (val) => widget.onEditChange(comic.id, val),
              onDoubleTap: () => widget.onEditStart(comic.id, 'title'),
              onEditingComplete: () => widget.onEditComplete(comic.id),
            )),
            DataCell(EditableTableCell(
              value: widget.editingField[comic.id] == 'writer'
                  ? (widget.editingValue[comic.id] ?? '')
                  : ((comic.writer ?? '').isNotEmpty ? comic.writer! : ''),
              isEditing: widget.editingField[comic.id] == 'writer',
              onChanged: (val) => widget.onEditChange(comic.id, val),
              onDoubleTap: () => widget.onEditStart(comic.id, 'writer'),
              onEditingComplete: () => widget.onEditComplete(comic.id),
            )),
            DataCell(EditableTableCell(
              value: widget.editingField[comic.id] == 'series' ? (widget.editingValue[comic.id] ?? '') : (comic.series ?? ''),
              isEditing: widget.editingField[comic.id] == 'series',
              onChanged: (val) => widget.onEditChange(comic.id, val),
              onDoubleTap: () => widget.onEditStart(comic.id, 'series'),
              onEditingComplete: () => widget.onEditComplete(comic.id),
            )),
            DataCell(Checkbox(
              value: comic.readingProgress?['read'] ?? false,
              onChanged: (checked) async {
                setState(() {
                  comic.readingProgress?['read'] = checked;
                });
                await ComicServices.saveReadState(comic.id, checked ?? false, context);
                Provider.of<ComicsProvider>(context, listen: false).updatecomic(comic);
              },
            )),
            DataCell(IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar metadatos globalmente',
              onPressed: widget.selectedComics.isNotEmpty ? widget.onBatchEdit : null,
            )),
          ],
        );
      }).toList(),
    );
  }
}
