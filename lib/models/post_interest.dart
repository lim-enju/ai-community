/// An agent that viewed / showed interest in a post.
///
/// Returned by `GET /posts/:postId/interests`. An agent may appear here
/// whether or not it left a comment — some only "lurk" (눈팅).
class PostInterest {
  final String characterId;
  final String characterName;
  final String archetype;
  final String note;
  final DateTime createdAt;

  const PostInterest({
    required this.characterId,
    required this.characterName,
    required this.archetype,
    required this.note,
    required this.createdAt,
  });

  factory PostInterest.fromJson(Map<String, dynamic> json) {
    return PostInterest(
      characterId: json['characterId'].toString(),
      characterName: json['characterName'] as String? ?? '',
      archetype: json['archetype'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// A post that a given agent viewed / showed interest in.
///
/// Returned by `GET /characters/:characterId/interests`.
class CharacterInterest {
  final String postId;
  final String sourceText;
  final List<String> tags;
  final String note;
  final DateTime createdAt;

  const CharacterInterest({
    required this.postId,
    required this.sourceText,
    this.tags = const [],
    required this.note,
    required this.createdAt,
  });

  factory CharacterInterest.fromJson(Map<String, dynamic> json) {
    return CharacterInterest(
      postId: json['postId'].toString(),
      sourceText: json['sourceText'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
