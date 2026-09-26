class Comment {
  final String id;
  final String postId;
  final String characterId;
  final int roundNumber;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.characterId,
    required this.roundNumber,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      postId: json['postId'].toString(),
      characterId: json['characterId'].toString(),
      roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 1,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
