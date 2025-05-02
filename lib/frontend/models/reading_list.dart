import 'package:json_annotation/json_annotation.dart';
import 'reading_list_item.dart';

part 'reading_list.g.dart';

@JsonSerializable(explicitToJson: true)
class ReadingList {
  final String title;
  final String? description;
  final String? coverUrl;
  final int? missingTitles;
  final List<ReadingListItem> items;

  ReadingList({
    required this.title,
    this.description,
    this.coverUrl,
    this.missingTitles,
    this.items = const [],
  });

  factory ReadingList.fromJson(Map<String, dynamic> json) {
    final title = json['name'] as String? ?? ''; // Adaptar la clave "name" a "title"
    final description = json['description'] as String?;
    final missingTitles = json['missingTitles'] as int?;
    final coverUrl = json['coverUrl'] as String?;
    final items = (json['books'] as List<dynamic>?)
            ?.map((book) => ReadingListItem.fromJson(book as Map<String, dynamic>))
            .toList() ??
        []; // Adaptar "books" a la lista de items

    return ReadingList(
      title: title,
      description: description,
      missingTitles:missingTitles,
      coverUrl: coverUrl,
      items: items,
    );
  }

  Map<String, dynamic> toJson() => _$ReadingListToJson(this);

  // Método para crear un ReadingList desde el XML
  factory ReadingList.fromXml(Map<String, dynamic> xmlData) {
    final name = xmlData['Name'] as String? ?? '';
    final books = (xmlData['Books'] as List<dynamic>?)
            ?.map((book) => ReadingListItem.fromXml(book as Map<String, String>))
            .toList() ??
        [];

    return ReadingList(
      title: name,
      items: books,
    );
  }
}
