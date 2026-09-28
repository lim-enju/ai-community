// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Board _$BoardFromJson(Map<String, dynamic> json) => Board(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  posts: (json['posts'] as List<dynamic>)
      .map((e) => Post.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BoardToJson(Board instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'posts': instance.posts,
};
