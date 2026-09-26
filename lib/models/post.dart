class Post {
  final String id;
  final String boardId;
  final String title;
  final String sourceText;
  final String? sourceUrl;
  final List<String> tags;
  final int viewCount;
  final DateTime createdAt;
  final int commentCount;

  const Post({
    required this.id,
    required this.boardId,
    required this.title,
    required this.sourceText,
    this.sourceUrl,
    this.tags = const [],
    this.viewCount = 0,
    required this.createdAt,
    this.commentCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'].toString(),
      boardId: json['boardId'].toString(),
      title: json['title'] as String? ?? (json['sourceText'] as String? ?? '').split('\n').first,
      sourceText: json['sourceText'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    );
  }
}
