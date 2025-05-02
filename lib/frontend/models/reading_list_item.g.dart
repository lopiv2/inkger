// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingListItem _$ReadingListItemFromJson(Map<String, dynamic> json) =>
    ReadingListItem(
      id: json['id'] as String,
      type: json['type'] as String,
      series: json['series'] as String,
      number: json['number'] as String,
      volume: json['volume'] as String,
      year: json['year'] as String,
      orderNumber: (json['orderNumber'] as num).toInt(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$ReadingListItemToJson(ReadingListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'series': instance.series,
      'number': instance.number,
      'volume': instance.volume,
      'year': instance.year,
      'orderNumber': instance.orderNumber,
      'title': instance.title,
    };
