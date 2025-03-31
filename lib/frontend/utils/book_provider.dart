import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/book.dart';
import 'package:inkger/frontend/services/book_services.dart';

class BooksProvider extends ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  void addBook(Book book) {
    _books.add(book);
    notifyListeners();
  }

  // Método para cargar libros desde la base de datos o la API
  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await BookServices.getAllBooks();
      if (response.statusCode == 200) {
        _books =
            (response.data as List)
                .map((bookData) => Book.fromMap(bookData))
                .toList();
      } else {
        throw Exception('Error al cargar los libros');
      }
    } catch (e) {
      throw Exception('Error al obtener los libros: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
