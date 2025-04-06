import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';

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
          child: _buildCoverImage(book.coverPath),
        ),
        title: Text(book.title),
        subtitle: book.author.isNotEmpty ? Text(book.author) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildCoverImage(String? coverPath, {bool calculateColor = false}) {
    return FutureBuilder<Uint8List?>(
      future: coverPath != null ? BookServices.getBookCover(coverPath) : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Icon(Icons.broken_image, size: 50));
        }

        // Cálculo del color solo cuando hay datos y es necesario
        /*if (calculateColor && !_colorCalculated && snapshot.hasData) {
          _calculateDominantColor(snapshot.data!);
          _colorCalculated = true;
        }*/

        return FittedBox(
          fit: BoxFit.contain,
          child: Image.memory(snapshot.data!, fit: BoxFit.contain),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.book, size: 24, color: Colors.grey),
      ),
    );
  }
}
