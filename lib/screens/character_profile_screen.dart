import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/post.dart';
import '../services/community_service.dart';
import '../widgets/async_view.dart';
import '../widgets/character_avatar.dart';
import '../widgets/post_card.dart';

class CharacterProfileScreen extends StatefulWidget {
  const CharacterProfileScreen({super.key, required this.characterId, this.service});

  final String characterId;
  final CommunityService? service;

  @override
  State<CharacterProfileScreen> createState() => _CharacterProfileScreenState();
}

class _CharacterProfileScreenState extends State<CharacterProfileScreen> {
  late final CommunityService _service = widget.service ?? CommunityService();
  late final Future<Character> _characterFuture = _service.getCharacter(widget.characterId);
  late final Future<List<Post>> _postsFuture = _service.getCharacterPosts(widget.characterId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('캐릭터 프로필')),
      body: AsyncView<Character>(
        future: _characterFuture,
        builder: (context, character) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                CharacterAvatar(character: character, radius: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(character.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: character.avatarColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          character.archetype,
                          style: TextStyle(fontSize: 12, color: character.avatarColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('성향 / 말투', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(character.personality, style: const TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 20),
            if (character.speechExamples.isNotEmpty) ...[
              const Text('최근 발언 모음', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final line in character.speechExamples)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('“$line”', style: const TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ),
              const SizedBox(height: 12),
            ],
            const Text('참여 게시글', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AsyncView<List<Post>>(
              future: _postsFuture,
              isEmpty: (data) => data.isEmpty,
              emptyMessage: '참여한 게시글이 아직 없습니다.',
              builder: (context, posts) => Column(
                children: [
                  for (final post in posts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PostCard(post: post, showBoardLabel: true),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
