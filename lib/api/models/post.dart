// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  const Post({
    required this.id,
    required this.boardId,
    required this.sourceText,
    required this.sourceUrl,
    required this.tags,
    required this.viewCount,
    required this.createdAt,
    this.commentCount,
  });
  
  factory Post.fromJson(Map<String, Object?> json) => _$PostFromJson(json);
  
  final String id;
  final String boardId;
  final String sourceText;
  final String? sourceUrl;
  final List<String> tags;
  final num viewCount;
  final DateTime createdAt;

  /// 파생값(DB 컬럼 아님). 목록 조회 시 QueryBuilder의.
  /// loadRelationCountAndMap으로 채워져 응답 JSON에 commentCount로 직렬화된다.
  final num? commentCount;

  Map<String, Object?> toJson() => _$PostToJson(this);
}
