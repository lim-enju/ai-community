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

  /// 본문에서 제목(첫 줄)을 제거한 나머지.
  /// 제목이 없어 sourceText 첫 줄로 유도된 경우, 카드/상세에서 첫 줄이
  /// 제목·본문으로 두 번 보이는 중복을 막는다. 단일 줄 글이면 빈 문자열.
  String get body {
    if (sourceText.startsWith(title)) {
      return sourceText.substring(title.length).trimLeft();
    }
    return sourceText;
  }

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
