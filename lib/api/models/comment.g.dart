// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['id'] as String,
  postId: json['postId'] as String,
  post: Post.fromJson(json['post'] as Map<String, dynamic>),
  characterId: json['characterId'] as String,
  character: Character.fromJson(json['character'] as Map<String, dynamic>),
  roundNumber: json['roundNumber'] as num,
  content: json['content'] as String,
  parentCommentId: json['parentCommentId'] as String?,
  parent: json['parent'] == null
      ? null
      : Comment.fromJson(json['parent'] as Map<String, dynamic>),
  replies: (json['replies'] as List<dynamic>)
      .map((e) => Comment.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'postId': instance.postId,
  'post': instance.post,
  'characterId': instance.characterId,
  'character': instance.character,
  'roundNumber': instance.roundNumber,
  'content': instance.content,
  'parentCommentId': instance.parentCommentId,
  'parent': instance.parent,
  'replies': instance.replies,
  'createdAt': instance.createdAt.toIso8601String(),
};
