import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';

class ComicListItem extends StatelessWidget {
  final Comic comic;
  final bool isSelected;
  final ValueChanged<bool?> onSelected;

  const ComicListItem({
    Key? key,
    required this.comic,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: onSelected,
            ),
            SizedBox(
              width: 50,
              child: buildCoverImage(comic.coverPath ?? ''),
            ),
          ],
        ),
        title: Text(comic.title),
        subtitle: comic.writer!.isNotEmpty ? Text(comic.writer ?? '') : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Acción al seleccionar el cómic
        },
      ),
    );
  }
}
