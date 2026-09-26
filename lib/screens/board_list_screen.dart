import 'package:flutter/material.dart';

import '../models/board.dart';
import '../models/post.dart';
import '../services/community_service.dart';
import '../theme/app_theme.dart';
import '../widgets/async_view.dart';
import '../widgets/post_card.dart';

class BoardListScreen extends StatefulWidget {
  const BoardListScreen({super.key, required this.board, this.service});

  final Board board;
  final CommunityService? service;

  @override
  State<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends State<BoardListScreen> {
  late final CommunityService _service = widget.service ?? CommunityService();
  String _sort = 'latest';
  String? _tagFilter;
  late Future<List<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getBoardPosts(widget.board.id, sort: _sort);
  }

  void _reload() {
    setState(() {
      _future = _service.getBoardPosts(widget.board.id, sort: _sort);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.board.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('최신순'),
                  selected: _sort == 'latest',
                  onSelected: (_) {
                    setState(() => _sort = 'latest');
                    _reload();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('인기순'),
                  selected: _sort == 'popular',
                  onSelected: (_) {
                    setState(() => _sort = 'popular');
                    _reload();
                  },
                ),
                const Spacer(),
                if (_tagFilter != null)
                  InputChip(
                    label: Text('#$_tagFilter'),
                    onDeleted: () => setState(() => _tagFilter = null),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView<List<Post>>(
              future: _future,
              isEmpty: (data) => data.isEmpty,
              emptyMessage: '${widget.board.name} 게시판에 아직 글이 없습니다.',
              builder: (context, posts) {
                final filtered = _tagFilter == null
                    ? posts
                    : posts.where((p) => p.tags.contains(_tagFilter)).toList();
                final tags = <String>{for (final p in posts) ...p.tags};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: tags
                              .map((t) => ActionChip(
                                    label: Text('#$t'),
                                    backgroundColor: AppColors.background,
                                    onPressed: () => setState(() => _tagFilter = t),
                                  ))
                              .toList(),
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => PostCard(post: filtered[i]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
