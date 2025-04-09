class Comic {
  final int id;
  final String title;
  final String? description;
  final int? fileSize;
  final String? filePath;
  final String? coverPath;
  final String? tags;
  final String? series;
  final int? seriesNumber;
  final String? language;
  final String? publisher;
  final String? storyArc;
  final String? alternateSeries;
  final String? writer;
  final String? penciller;
  final String? inker;
  final String? colorist;
  final String? letterer;
  final String? coverArtist;
  final String? editor;
  final int? pages;
  final String? characters; // Podría ser String, List<String> o Map
  final String? teams;
  final String? locations;
  final int? volume;
  final String? web;
  final DateTime? publicationDate;
  final DateTime creationDate;
  final Map<String, dynamic>? readingProgress; // Añade este campo

  Comic({
    required this.id,
    required this.title,
    this.description,
    this.fileSize,
    this.filePath,
    this.coverPath,
    this.tags,
    this.series,
    this.seriesNumber,
    this.language,
    this.publisher,
    this.storyArc,
    this.alternateSeries,
    this.writer,
    this.penciller,
    this.inker,
    this.colorist,
    this.letterer,
    this.coverArtist,
    this.editor,
    this.pages,
    this.characters,
    this.teams,
    this.locations,
    this.volume,
    this.web,
    this.publicationDate,
    required this.creationDate,
    this.readingProgress,
  });

  factory Comic.fromMap(Map<String, dynamic> map) {
    return Comic(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      readingProgress: map['readingProgress'], // Añadido aquí
      fileSize: map['fileSize'],
      filePath: map['filePath'],
      coverPath: map['coverPath'],
      tags: map['tags'],
      series: map['series'],
      seriesNumber: map['seriesNumber'],
      language: map['language'],
      publisher: map['publisher'],
      storyArc: map['storyArc'],
      alternateSeries: map['alternateSeries'],
      writer: map['writer'],
      penciller: map['penciller'],
      inker: map['inker'],
      colorist: map['colorist'],
      letterer: map['letterer'],
      coverArtist: map['coverArtist'],
      editor: map['editor'],
      pages: map['pages'],
      characters: map['characters'],
      teams: map['teams'],
      locations: map['locations'],
      volume: map['volume'],
      web: map['web'],
      publicationDate:
          map['publicationDate'] != null
              ? DateTime.parse(map['publicationDate'])
              : null,
      creationDate: DateTime.parse(map['creationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fileSize': fileSize,
      'filePath': filePath,
      'coverPath': coverPath,
      'tags': tags,
      'series': series,
      'seriesNumber': seriesNumber,
      'language': language,
      'publisher': publisher,
      'storyArc': storyArc,
      'alternateSeries': alternateSeries,
      'writer': writer,
      'penciller': penciller,
      'inker': inker,
      'colorist': colorist,
      'letterer': letterer,
      'coverArtist': coverArtist,
      'editor': editor,
      'pages': pages,
      'characters': characters,
      'teams': teams,
      'locations': locations,
      'volume': volume,
      'web': web,
      'publicationDate': publicationDate?.toIso8601String(),
      'creationDate': creationDate.toIso8601String(),
      'readingProgress': readingProgress,
    };
  }

  // Método para convertir JSON strings a List (opcional)
  List<String>? getCharactersList() {
    if (characters == null) return null;
    if (characters is List) return List<String>.from(characters as List);
    if (characters is String)
      return (characters as String).split(',').map((e) => e.trim()).toList();
    return null;
  }
}
