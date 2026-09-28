import 'package:flutter/material.dart';

import '../models/board.dart';
import '../models/post.dart';
import '../services/community_service.dart';
import '../theme/app_theme.dart';
import '../widgets/async_view.dart';
import '../widgets/post_card.dart';
import 'analytics_screen.dart';
import 'board_list_screen.dart';
import 'character_list_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.service});

  final CommunityService? service;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final CommunityService _service = widget.service ?? CommunityService();
  late Future<List<Board>> _boardsFuture;
  late Future<List<Post>> _bestFuture;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _boardsFuture = _service.getBoards();
    _bestFuture = _service.getBestPosts();
    _boardsFuture.then((boards) {
      if (!mounted) return;
      // build()와 동일하게 '베스트'(집계용 가상 게시판)를 제외한 개수로 맞춰,
      // 컨트롤러가 불필요하게 재생성되지 않도록 한다.
      final tabCount = boards.where((b) => b.slug != 'best').length;
      setState(() {
        _tabController?.dispose();
        _tabController = TabController(length: tabCount, vsync: this);
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 토론 커뮤니티'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.groups_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CharacterListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: '에이전트 분석',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _boardsFuture = _service.getBoards();
            _bestFuture = _service.getBestPosts();
          });
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader(title: '오늘의 베스트글', icon: Icons.local_fire_department_outlined),
            const SizedBox(height: 8),
            AsyncView<List<Post>>(
              future: _bestFuture,
              isEmpty: (data) => data.isEmpty,
              emptyMessage: '베스트글이 아직 없습니다.',
              builder: (context, posts) => Column(
                children: [
                  for (final post in posts.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PostCard(post: post, showBoardLabel: true),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: '게시판별 최신글', icon: Icons.dashboard_outlined),
            const SizedBox(height: 8),
            AsyncView<List<Board>>(
              future: _boardsFuture,
              isEmpty: (data) => data.isEmpty,
              builder: (context, boards) {
                // '베스트'는 실제 글이 없는 집계용 가상 게시판이라(상단 '오늘의 베스트글' 섹션에서 이미 노출)
                // 게시판별 최신글 탭에서는 제외한다. 그렇지 않으면 첫 탭이 비어 보인다.
                final tabBoards = boards.where((b) => b.slug != 'best').toList();
                if (_tabController == null || _tabController!.length != tabBoards.length) {
                  _tabController?.dispose();
                  _tabController = TabController(length: tabBoards.length, vsync: this);
                }
                return Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: AppColors.navy,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.accent,
                      tabs: tabBoards.map((b) => Tab(text: b.name)).toList(),
                    ),
                    SizedBox(
                      height: 360,
                      child: TabBarView(
                        controller: _tabController,
                        children: tabBoards
                            .map((board) => _BoardPreview(service: _service, board: board))
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardPreview extends StatelessWidget {
  const _BoardPreview({required this.service, required this.board});

  final CommunityService service;
  final Board board;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AsyncView<List<Post>>(
            future: service.getBoardPosts(board.id, sort: 'latest'),
            isEmpty: (data) => data.isEmpty,
            emptyMessage: '${board.name} 게시판에 글이 없습니다.',
            builder: (context, posts) => ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              children: [
                for (final post in posts.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PostCard(post: post),
                  ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BoardListScreen(board: board)),
            ),
            child: Text('${board.name} 게시판 전체보기 >'),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.navy, size: 20),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
