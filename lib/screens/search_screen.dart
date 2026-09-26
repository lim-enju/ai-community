import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/community_service.dart';
import '../widgets/async_view.dart';
import '../widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.service});

  final CommunityService? service;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final CommunityService _service = widget.service ?? CommunityService();
  final _controller = TextEditingController();
  String? _tag;
  Future<List<Post>>? _future;

  void _runSearch() {
    setState(() {
      _future = _service.search(query: _controller.text.trim(), tag: _tag);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('검색')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _runSearch(),
              decoration: InputDecoration(
                hintText: '키워드 또는 태그로 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _runSearch,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _future == null
                ? const Center(child: Text('검색어를 입력해 보세요.'))
                : AsyncView<List<Post>>(
                    future: _future!,
                    isEmpty: (data) => data.isEmpty,
                    emptyMessage: '검색 결과가 없습니다.',
                    builder: (context, posts) => ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: posts.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => PostCard(post: posts[i], showBoardLabel: true),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
