class Comment {
  final String id;
  final String postId;
  final String characterId;
  final int roundNumber;
  final String content;
  final DateTime createdAt;

  /// Id of the parent comment when this is a reply (대댓글). `null` for a
  /// top-level comment.
  final String? parentCommentId;

  const Comment({
    required this.id,
    required this.postId,
    required this.characterId,
    required this.roundNumber,
    required this.content,
    required this.createdAt,
    this.parentCommentId,
  });

  bool get isReply => parentCommentId != null;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      postId: json['postId'].toString(),
      characterId: json['characterId'].toString(),
      roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 1,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      parentCommentId: json['parentCommentId']?.toString(),
    );
  }
}
