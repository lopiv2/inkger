// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingList _$ReadingListFromJson(Map<String, dynamic> json) => ReadingList(
  title: json['title'] as String,
  description: json['description'] as String?,
  coverUrl: json['coverUrl'] as String?,
  missingTitles: (json['missingTitles'] as num?)?.toInt(),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ReadingListItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ReadingListToJson(ReadingList instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'coverUrl': instance.coverUrl,
      'missingTitles': instance.missingTitles,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
