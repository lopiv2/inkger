import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:inkger/frontend/models/epub_book.dart';
import 'package:inkger/frontend/utils/functions.dart';

class CustomEpubReader extends StatefulWidget {
  final String epubPath;
  final String coverPath;

  const CustomEpubReader({required this.epubPath, required this.coverPath});

  @override
  _CustomEpubReaderState createState() => _CustomEpubReaderState();
}

class _CustomEpubReaderState extends State<CustomEpubReader> {
  late Future<EpubBook> _bookFuture;
  final _pageController = PageController();
  final _textStyle = TextStyle(fontSize: 16, height: 1.5);
  double _fontSize = 16;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _bookFuture = parseEpub(widget.epubPath, widget.coverPath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EpubBook>(
      future: _bookFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }
        
        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error!);
        }

        return _buildReaderUI(snapshot.data!);
      },
    );
  }

  Widget _buildReaderUI(EpubBook book) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(
            icon: Icon(_darkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _darkMode = !_darkMode),
          ),
          IconButton(
            icon: Icon(Icons.text_fields),
            onPressed: _showFontSizeDialog,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: book.chapters.length,
        itemBuilder: (context, index) {
          return Container(
            color: _darkMode ? Colors.grey[850] : Colors.white,
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Html(
                data: book.chapters[index].content,
                style: {
                  "body": Style(
                    fontSize: FontSize(_fontSize),
                    color: _darkMode ? Colors.white : Colors.black,
                    lineHeight: LineHeight(1.6),
                  ),
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tamaño de texto"),
        content: Slider(
          value: _fontSize,
          min: 12,
          max: 24,
          divisions: 6,
          label: _fontSize.round().toString(),
          onChanged: (value) => setState(() => _fontSize = value),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() => Center(child: CircularProgressIndicator());

  Widget _buildErrorScreen(dynamic error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 50, color: Colors.red),
            SizedBox(height: 20),
            Text("Error al cargar el libro:"),
            Text(error.toString()),
          ],
        ),
      );
}