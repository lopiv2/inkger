import 'dart:io';
import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';

class EpubReaderScreen extends StatefulWidget {
  final String epubPath;

  const EpubReaderScreen({required this.epubPath});

  @override
  _EpubReaderScreenState createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  EpubBook? _book;
  List<String> _chapters = [];

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  Future<void> _loadEpub() async {
    try {
      final file = File(widget.epubPath);
      final Uint8List bytes = await file.readAsBytes();
      final EpubBook book = await EpubReader.readBook(bytes);

      List<String> chapters = [];
      for (var chapter in book.Chapters!) {
        chapters.add(chapter.HtmlContent ?? "Sin contenido");
      }

      setState(() {
        _book = book;
        _chapters = chapters;
      });
    } catch (e) {
      print("Error al cargar el EPUB: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_book?.Title ?? "Cargando...")),
      body: _book == null
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(_chapters[index]),
                  ),
                );
              },
            ),
    );
  }
}
