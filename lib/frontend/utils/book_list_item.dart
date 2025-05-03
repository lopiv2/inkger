import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/widgets/cover_art.dart';

class BookListItem extends StatelessWidget {
  final Book book;

  const BookListItem({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          child: buildCoverImage(book.coverPath ?? ''),
        ),
        title: Text(book.title),
        subtitle: book.author.isNotEmpty ? Text(book.author) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }


  /*Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.book, size: 24, color: Colors.grey),
      ),
    );
  }*/
}
