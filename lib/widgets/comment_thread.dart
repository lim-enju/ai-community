import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../models/character.dart';
import '../models/comment.dart';
import '../screens/character_profile_screen.dart';
import '../theme/app_theme.dart';
import 'character_avatar.dart';

/// 댓글의 characterId(실제 UUID)를 실제 캐릭터로 해석한다.
///
/// [charactersById]에 실제 캐릭터가 있으면 그 이름/아키타입을 쓰되, 실제 캐릭터는
/// 색상 정보가 없으므로 같은 아키타입의 mock 색상을 빌려 아바타 색 다양성을 유지한다.
/// 매칭 실패 시에만 mock 캐릭터로 폴백한다.
Character resolveCharacter(String characterId, Map<String, Character> charactersById) {
  final real = charactersById[characterId];
  if (real == null) {
    return MockData.characterById(characterId);
  }
  final mockForColor = MockData.characters.firstWhere(
    (m) => m.archetype == real.archetype,
    orElse: () => MockData.characterById(characterId),
  );
  return Character(
    id: real.id,
    name: real.name,
    archetype: real.archetype,
    speechExamples: real.speechExamples,
    personality: real.personality,
    avatarColor: mockForColor.avatarColor,
  );
}

/// Renders the character discussion for a post.
///
/// Top-level comments (`parentCommentId == null`) are grouped by round.
/// Replies (대댓글) are nested underneath the comment they reply to, with an
/// indent that grows with nesting depth.
class CommentThread extends StatelessWidget {
  const CommentThread({super.key, required this.comments, this.charactersById = const {}});

  final List<Comment> comments;

  /// 실제 캐릭터 조회 결과(id → Character). 비어 있으면 mock으로 폴백한다.
  final Map<String, Character> charactersById;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('아직 캐릭터 댓글이 없습니다.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    // Index replies by their parent id.
    final childrenOf = <String, List<Comment>>{};
    for (final c in comments) {
      if (c.parentCommentId != null) {
        childrenOf.putIfAbsent(c.parentCommentId!, () => []).add(c);
      }
    }
    for (final list in childrenOf.values) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    // Group top-level comments by round.
    final rounds = <int, List<Comment>>{};
    for (final c in comments.where((c) => c.parentCommentId == null)) {
      rounds.putIfAbsent(c.roundNumber, () => []).add(c);
    }
    final roundKeys = rounds.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final round in roundKeys) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'ROUND $round',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),
          for (final comment in rounds[round]!)
            ..._buildWithReplies(comment, childrenOf, 0),
        ],
      ],
    );
  }

  /// Emits a comment tile followed by its (recursively nested) replies.
  List<Widget> _buildWithReplies(
    Comment comment,
    Map<String, List<Comment>> childrenOf,
    int depth,
  ) {
    return [
      _CommentTile(comment: comment, depth: depth, charactersById: charactersById),
      for (final reply in childrenOf[comment.id] ?? const <Comment>[])
        ..._buildWithReplies(reply, childrenOf, depth + 1),
    ];
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, this.depth = 0, this.charactersById = const {}});

  final Comment comment;
  final int depth;
  final Map<String, Character> charactersById;

  @override
  Widget build(BuildContext context) {
    final character = resolveCharacter(comment.characterId, charactersById);
    final isReply = depth > 0;
    // Indent replies; cap the visual indent so deep threads stay readable.
    final indent = (depth.clamp(0, 3)) * 24.0;

    final tile = Container(
      padding: isReply ? const EdgeInsets.fromLTRB(10, 8, 4, 8) : const EdgeInsets.symmetric(vertical: 8),
      decoration: isReply
          ? BoxDecoration(
              border: Border(
                left: BorderSide(color: character.avatarColor.withValues(alpha: 0.35), width: 2),
              ),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReply)
            const Padding(
              padding: EdgeInsets.only(top: 4, right: 4),
              child: Icon(Icons.subdirectory_arrow_right, size: 16, color: AppColors.textSecondary),
            ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CharacterProfileScreen(characterId: character.id),
              ),
            ),
            child: CharacterAvatar(character: character, radius: isReply ? 16 : 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        character.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: character.avatarColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        character.archetype,
                        style: TextStyle(fontSize: 10, color: character.avatarColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 13.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );

    if (indent == 0) return tile;
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: tile,
    );
  }
}
