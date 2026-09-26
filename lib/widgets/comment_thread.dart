import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../models/comment.dart';
import '../screens/character_profile_screen.dart';
import '../theme/app_theme.dart';
import 'character_avatar.dart';

class CommentThread extends StatelessWidget {
  const CommentThread({super.key, required this.comments});

  final List<Comment> comments;

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
    final rounds = <int, List<Comment>>{};
    for (final c in comments) {
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
          for (final comment in rounds[round]!) _CommentTile(comment: comment),
        ],
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final character = MockData.characterById(comment.characterId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CharacterProfileScreen(characterId: character.id),
              ),
            ),
            child: CharacterAvatar(character: character),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(character.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
  }
}
