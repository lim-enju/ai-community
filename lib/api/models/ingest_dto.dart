// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'ingest_dto.g.dart';

@JsonSerializable()
class IngestDto {
  const IngestDto({
    required this.boardId,
    required this.sourceText,
    this.sourceUrl,
    this.tags,
  });
  
  factory IngestDto.fromJson(Map<String, Object?> json) => _$IngestDtoFromJson(json);
  
  final String boardId;
  final String sourceText;
  final String? sourceUrl;
  final List<String>? tags;

  Map<String, Object?> toJson() => _$IngestDtoToJson(this);
}
