class Board {
  final String id;
  final String name;
  final String slug;
  final String description;

  const Board({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
