// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['id'] as String,
  postId: json['postId'] as String,
  characterId: json['characterId'] as String,
  roundNumber: json['roundNumber'] as num,
  content: json['content'] as String,
  parentCommentId: json['parentCommentId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'postId': instance.postId,
  'characterId': instance.characterId,
  'roundNumber': instance.roundNumber,
  'content': instance.content,
  'parentCommentId': instance.parentCommentId,
  'createdAt': instance.createdAt.toIso8601String(),
};
