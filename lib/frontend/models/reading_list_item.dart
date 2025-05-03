import 'package:json_annotation/json_annotation.dart';

part 'reading_list_item.g.dart';

@JsonSerializable()
class ReadingListItem {
  final String id; // Mapeado desde "Issue"
  final String readingListId; // Mapeado desde "ReadingListId"
  final String type; // 'comic', 'audiobook', 'book'
  final String series;
  final String number;
  final String volume;
  final String year;
  final int orderNumber; // Nuevo campo para el orden
  final String title; // Nuevo campo para el título
  final String itemId; // Nuevo campo para el título

  ReadingListItem({
    required this.id,
    required this.readingListId,
    required this.type,
    required this.series,
    required this.number,
    required this.volume,
    required this.year,
    required this.orderNumber, // Inicializar el nuevo campo
    required this.title, // Inicializar el nuevo campo
    required this.itemId, // Inicializar el nuevo campo
  });

  factory ReadingListItem.fromJson(Map<String, dynamic> json) {
    return ReadingListItem(
      id: json['id'] as String? ?? '', // Adaptar "issueId" a "id"
      readingListId: json['readingListId'] as String? ?? '', // Adaptar "issueId" a "id"
      type: json['type'] as String? ?? 'comic', // Valor predeterminado 'comic'
      series: json['series'] as String? ?? '',
      number: json['number'] as String? ?? '',
      volume: json['volume'] as String? ?? '',
      year: json['year'] as String? ?? '',
      orderNumber: json['orderNumber'] as int? ?? 0, // Asignar valor predeterminado 0
      title: json['title'] as String? ?? '', // Asignar valor predeterminado vacío
      itemId: json['itemId'] as String? ?? '', // Asignar valor predeterminado vacío
    );
  }

  Map<String, dynamic> toJson() => _$ReadingListItemToJson(this);

  // Método para crear un ReadingListItem desde el XML
  factory ReadingListItem.fromXml(Map<String, String> xmlAttributes) {
    return ReadingListItem(
      id: xmlAttributes['Issue'] ?? '',
      readingListId: xmlAttributes['readingListId'] ?? '',
      type: 'comic', // Asumido como 'comic' por defecto
      series: xmlAttributes['Series'] ?? '',
      number: xmlAttributes['Number'] ?? '',
      volume: xmlAttributes['Volume'] ?? '',
      year: xmlAttributes['Year'] ?? '',
      orderNumber: int.tryParse(xmlAttributes['OrderNumber'] ?? '0') ?? 0, // Parsear el orden
      title: xmlAttributes['Title'] ?? '', // Asignar valor predeterminado vacío
      itemId: xmlAttributes['ItemId'] ?? '', // Asignar valor predeterminado vacío
    );
  }
}
