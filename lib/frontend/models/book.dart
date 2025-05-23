import 'package:intl/intl.dart';

class Book {
  final int id;
  final String title;
  final String author;
  final DateTime publicationDate;
  final DateTime creationDate;
  final String? description;
  final String? publisher;
  final String? language;
  final String? coverPath;
  final int? pages;
  final dynamic identifiers; // Usamos dynamic para Json
  final String? tags;
  final String? series;
  final int? seriesNumber;
  final Map<String, dynamic>? readingProgress; // Añade este campo
  final int? fileSize;
  final String? filePath;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publicationDate,
    required this.creationDate,
    this.description,
    this.publisher,
    this.language,
    this.coverPath,
    this.pages,
    this.identifiers,
    this.tags,
    this.series,
    this.seriesNumber,
    this.readingProgress,
    this.fileSize,
    this.filePath,
  });

  // Método para convertir un JSON en un objeto Book
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      publicationDate: DateTime.parse(json['publicationDate']),
      creationDate: DateTime.parse(json['creationDate']),
      description: json['description'],
      publisher: json['publisher'],
      language: json['language'],
      coverPath: json['coverPath'],
      pages: json['pages'],
      identifiers: json['identifiers'],
      tags: json['tags'],
      series: json['series'],
      seriesNumber: json['seriesNumber'],
      readingProgress: json['readingProgress'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['readingProgress'])
          : {'progress': json['readingProgress']},
      fileSize: json['fileSize'],
      filePath: json['filePath'],
    );
  }

  // Método para convertir el objeto Book a un Map (útil para guardar en la base de datos)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publicationDate': publicationDate.toIso8601String(),
      'creationDate': creationDate.toIso8601String(),
      'description': description,
      'publisher': publisher,
      'language': language,
      'coverPath': coverPath,
      'pages': pages,
      'identifiers': identifiers,
      'tags': tags,
      'series': series,
      'seriesNumber': seriesNumber,
      'readingProgress': readingProgress,
      'fileSize': fileSize,
      'filePath': filePath,
    };
  }

  static empty() {}
}

extension BookExtensions on Book {
  Map<String, String> toDisplayMap() {
    final dateFormat = DateFormat('yyyy-MM-dd'); // o el formato que prefieras

    return {
      'title': title,
      'author': author,
      'publicationDate': dateFormat.format(publicationDate),
      'creationDate': dateFormat.format(creationDate),
      'description': description ?? '',
      'publisher': publisher ?? '',
      'language': language ?? '',
      'coverPath': coverPath ?? '',
      'pages': pages?.toString() ?? '',
      'identifiers': identifiers?.toString() ?? '',
      'tags': tags ?? '',
      'series': series ?? '',
      'seriesNumber': seriesNumber?.toString() ?? '',
      'fileSize': fileSize?.toString() ?? '',
      'filePath': filePath ?? '',
    };
  }
}
