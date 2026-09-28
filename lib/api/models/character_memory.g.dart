// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_memory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterMemory _$CharacterMemoryFromJson(Map<String, dynamic> json) =>
    CharacterMemory(
      id: json['id'] as String,
      characterId: json['characterId'] as String,
      character: Character.fromJson(json['character'] as Map<String, dynamic>),
      summarizedStance: json['summarizedStance'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CharacterMemoryToJson(CharacterMemory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'characterId': instance.characterId,
      'character': instance.character,
      'summarizedStance': instance.summarizedStance,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
