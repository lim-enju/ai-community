/// Aggregated interest statistics.
///
/// Returned by `GET /analytics/interest-overview`.
class InterestOverview {
  final List<CharacterViewStat> perCharacter;
  final List<TopInterestPost> topPosts;

  const InterestOverview({
    this.perCharacter = const [],
    this.topPosts = const [],
  });

  factory InterestOverview.fromJson(Map<String, dynamic> json) {
    return InterestOverview(
      perCharacter: (json['perCharacter'] as List<dynamic>?)
              ?.map((e) => CharacterViewStat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      topPosts: (json['topPosts'] as List<dynamic>?)
              ?.map((e) => TopInterestPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

/// Number of posts a single agent viewed.
class CharacterViewStat {
  final String characterId;
  final String characterName;
  final int viewedPosts;

  const CharacterViewStat({
    required this.characterId,
    required this.characterName,
    required this.viewedPosts,
  });

  factory CharacterViewStat.fromJson(Map<String, dynamic> json) {
    return CharacterViewStat(
      characterId: json['characterId'].toString(),
      characterName: json['characterName'] as String? ?? '',
      viewedPosts: (json['viewedPosts'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A post ranked by how many agents were interested in it.
class TopInterestPost {
  final String postId;
  final String sourceText;
  final int interestedAgents;

  const TopInterestPost({
    required this.postId,
    required this.sourceText,
    required this.interestedAgents,
  });

  factory TopInterestPost.fromJson(Map<String, dynamic> json) {
    return TopInterestPost(
      postId: json['postId'].toString(),
      sourceText: json['sourceText'] as String? ?? '',
      interestedAgents: (json['interestedAgents'] as num?)?.toInt() ?? 0,
    );
  }
}
