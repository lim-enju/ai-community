// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: json['id'] as String,
  boardId: json['boardId'] as String,
  sourceText: json['sourceText'] as String,
  sourceUrl: json['sourceUrl'] as String?,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  viewCount: json['viewCount'] as num,
  createdAt: DateTime.parse(json['createdAt'] as String),
  commentCount: json['commentCount'] as num?,
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'boardId': instance.boardId,
  'sourceText': instance.sourceText,
  'sourceUrl': instance.sourceUrl,
  'tags': instance.tags,
  'viewCount': instance.viewCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'commentCount': instance.commentCount,
};
