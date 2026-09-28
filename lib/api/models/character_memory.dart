// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'character.dart';

part 'character_memory.g.dart';

@JsonSerializable()
class CharacterMemory {
  const CharacterMemory({
    required this.id,
    required this.characterId,
    required this.character,
    required this.summarizedStance,
    required this.updatedAt,
  });
  
  factory CharacterMemory.fromJson(Map<String, Object?> json) => _$CharacterMemoryFromJson(json);
  
  final String id;
  final String characterId;
  final Character character;
  final String summarizedStance;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$CharacterMemoryToJson(this);
}
