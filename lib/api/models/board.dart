// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post.dart';

part 'board.g.dart';

@JsonSerializable()
class Board {
  const Board({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.posts,
  });
  
  factory Board.fromJson(Map<String, Object?> json) => _$BoardFromJson(json);
  
  final String id;
  final String name;
  final String slug;
  final String? description;
  final List<Post> posts;

  Map<String, Object?> toJson() => _$BoardToJson(this);
}
