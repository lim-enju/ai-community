// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'character.dart';
import 'comment.dart';
import 'post.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.post,
    required this.characterId,
    required this.character,
    required this.roundNumber,
    required this.content,
    required this.parentCommentId,
    required this.parent,
    required this.replies,
    required this.createdAt,
  });
  
  factory Comment.fromJson(Map<String, Object?> json) => _$CommentFromJson(json);
  
  final String id;
  final String postId;
  final Post post;
  final String characterId;
  final Character character;
  final num roundNumber;
  final String content;
  final String? parentCommentId;
  final Comment? parent;
  final List<Comment> replies;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$CommentToJson(this);
}
