import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/community_service.dart';
import '../theme/app_theme.dart';
import '../widgets/async_view.dart';
import '../widgets/character_avatar.dart';
import 'character_profile_screen.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key, this.service});

  final CommunityService? service;

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  late final CommunityService _service = widget.service ?? CommunityService();
  late final Future<List<Character>> _future = _service.getCharacters();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('캐릭터 소개')),
      body: AsyncView<List<Character>>(
        future: _future,
        isEmpty: (data) => data.isEmpty,
        builder: (context, characters) => ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: characters.length,
          separatorBuilder: (_, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final c = characters[i];
            return Card(
              child: ListTile(
                leading: CharacterAvatar(character: c),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c.archetype, style: const TextStyle(color: AppColors.textSecondary)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CharacterProfileScreen(characterId: c.id)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
