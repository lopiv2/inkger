import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';

class BookListItem extends StatelessWidget {
  final Book book;
  final bool isSelected;
  final ValueChanged<bool?> onSelected;

  const BookListItem({
    Key? key,
    required this.book,
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
            Checkbox(value: isSelected, onChanged: onSelected),
            SizedBox(width: 50, child: buildCoverImage(book.coverPath ?? '')),
          ],
        ),
        title: Text(book.title),
        subtitle: book.author.isNotEmpty ? Text(book.author) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Acción al seleccionar el cómic
        },
      ),
    );
  }
}
