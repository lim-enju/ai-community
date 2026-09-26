import 'package:flutter/material.dart';

import '../models/character.dart';

class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({super.key, required this.character, this.radius = 20});

  final Character character;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = character.name.isNotEmpty ? character.name.substring(0, 1) : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: character.avatarColor,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
