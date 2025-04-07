import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/services/book_services.dart';

class ComicListItem extends StatelessWidget {
  final Comic comic;

  const ComicListItem({Key? key, required this.comic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          child: _buildCoverImage(comic.coverPath),
        ),
        title: Text(comic.title),
        subtitle: comic.writer!.isNotEmpty ? Text(comic.writer ?? '') : null,
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

        return FittedBox(
          fit: BoxFit.contain,
          child: Image.memory(snapshot.data!, fit: BoxFit.contain),
        );
      },
    );
  }
}
