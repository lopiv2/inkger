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
    this.identifiers,
    this.tags,
    this.series,
    this.seriesNumber,
    this.readingProgress,
    this.fileSize,
    this.filePath,
  });

  // Método para convertir un Map en un objeto Book (útil para la base de datos)
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      publicationDate: DateTime.parse(map['publicationDate']),
      creationDate: DateTime.parse(map['creationDate']),
      description: map['description'],
      publisher: map['publisher'],
      language: map['language'],
      coverPath: map['coverPath'],
      identifiers: map['identifiers'],
      tags: map['tags'],
      series: map['series'],
      seriesNumber: map['seriesNumber'],
      readingProgress: map['readingProgress'],
      fileSize: map['fileSize'],
      filePath: map['filePath'],
    );
  }

  // Método para convertir el objeto Book a un Map (útil para guardar en la base de datos)
  Map<String, dynamic> toMap() {
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
      'identifiers': identifiers,
      'tags': tags,
      'series': series,
      'seriesNumber': seriesNumber,
      'readingProgress': readingProgress,
      'fileSize': fileSize,
      'filePath': filePath,
    };
  }
}
