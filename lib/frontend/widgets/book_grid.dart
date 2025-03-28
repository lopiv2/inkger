import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

class BooksGrid extends StatefulWidget {
  @override
  State<BooksGrid> createState() => _BooksGridState();
}

class _BooksGridState extends State<BooksGrid> {
  @override
  void initState() {
    super.initState();
    // Cargar libros al iniciar la pantalla
    Provider.of<BooksProvider>(context, listen: false).loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Libros")),
      body: Consumer<BooksProvider>(
        builder: (context, booksProvider, child) {
          final books = booksProvider.books;

          if (books.isEmpty) {
            return Center(child: Text("No hay libros disponibles"));
          }

          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7, // Controla la proporción ancho/alto
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final coverPath = book.coverPath; // Nombre del libro

              return Column(
                mainAxisSize:
                    MainAxisSize
                        .min, // Evita que la columna ocupe todo el espacio disponible
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FutureBuilder<Uint8List?>(
                        future:
                            coverPath != null
                                ? BookServices.getBookCover(coverPath)
                                : null,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              width: double.infinity,
                              height: 150, // Ajusta la altura según necesites
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Container(
                              width: double.infinity,
                              height: 150,
                              alignment: Alignment.center,
                              child: Icon(Icons.broken_image, size: 50),
                            );
                          }
                          return Image.memory(
                            snapshot.data!,
                            width: double.infinity,
                            height: 150, // Ajusta la altura según necesites
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 4), // Espacio entre la imagen y el título
                  Text(
                    book.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Ajusta el tamaño según necesites
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
