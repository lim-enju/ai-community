import 'package:flutter/material.dart';

class Character {
  final String id;
  final String name;
  final String archetype;
  final List<String> speechExamples;
  final String personality;
  final Color avatarColor;

  const Character({
    required this.id,
    required this.name,
    required this.archetype,
    this.speechExamples = const [],
    required this.personality,
    required this.avatarColor,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      archetype: json['archetype'] as String? ?? '',
      speechExamples: (json['speechExamples'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      personality: json['personality'] as String? ?? '',
      avatarColor: _parseColor(json['avatarColor'] as String?),
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null) return Colors.blueGrey;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value != null ? Color(value) : Colors.blueGrey;
  }
}
