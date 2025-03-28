import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';

class BooksProvider extends ChangeNotifier {
  List<Book> _books = [];

  List<Book> get books => _books;

  void addBook(Book book) {
    _books.add(book);
    notifyListeners();
  }

  // Método para cargar libros desde la base de datos o la API
  Future<void> loadBooks() async {
    try {
      final response =
          await BookServices.getAllBooks(); // Asumiendo que BookServices tiene un método para obtener los libros
      if (response.statusCode == 200) {
        List<Book> booksList =
            (response.data as List)
                .map(
                  (bookData) => Book(
                    id: bookData['id'],
                    title: bookData['title'],
                    author: bookData['author'],
                    publicationDate: DateTime.parse(
                      bookData['publicationDate'],
                    ),
                    creationDate: DateTime.parse(bookData['creationDate']),
                    description: bookData['description'],
                    publisher: bookData['publisher'],
                    language: bookData['language'],
                    coverPath: bookData['coverPath'],
                    identifiers: bookData['identifiers'],
                    tags: bookData['tags'],
                    series: bookData['series'],
                    seriesNumber: bookData['seriesNumber'],
                    read:
                        bookData['read'] ??
                        false, // Si existe el campo "read", usarlo
                    fileSize: bookData['fileSize'],
                    filePath: bookData['filePath'],
                  ),
                )
                .toList();
        setBooks(booksList);
      } else {
        throw Exception('Error al cargar los libros');
      }
    } catch (e) {
      throw Exception('Error al obtener los libros: $e');
    }
  }

  void removeBook(int id) {
    _books.removeWhere((book) => book.id == id);
    notifyListeners();
  }

  void updateBook(Book updatedBook) {
    int index = _books.indexWhere((book) => book.id == updatedBook.id);
    if (index != -1) {
      _books[index] = updatedBook;
      notifyListeners();
    }
  }

  void setBooks(List<Book> newBooks) {
    _books = newBooks;
    notifyListeners();
  }
}
