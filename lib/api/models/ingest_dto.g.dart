// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingest_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngestDto _$IngestDtoFromJson(Map<String, dynamic> json) => IngestDto(
  boardId: json['boardId'] as String,
  sourceText: json['sourceText'] as String,
  sourceUrl: json['sourceUrl'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$IngestDtoToJson(IngestDto instance) => <String, dynamic>{
  'boardId': instance.boardId,
  'sourceText': instance.sourceText,
  'sourceUrl': instance.sourceUrl,
  'tags': instance.tags,
};
