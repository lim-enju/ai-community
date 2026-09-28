// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'character_archetype.dart';

part 'character.g.dart';

@JsonSerializable()
class Character {
  const Character({
    required this.id,
    required this.name,
    required this.archetype,
    required this.speechExamples,
    required this.personality,
    required this.argumentPattern,
    required this.responseLengthGuide,
  });
  
  factory Character.fromJson(Map<String, Object?> json) => _$CharacterFromJson(json);
  
  final String id;
  final String name;
  final CharacterArchetype archetype;
  final List<String> speechExamples;
  final String personality;
  final String argumentPattern;
  final String responseLengthGuide;

  Map<String, Object?> toJson() => _$CharacterToJson(this);
}
