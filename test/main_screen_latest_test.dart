import 'package:ai_community/models/board.dart';
import 'package:ai_community/models/post.dart';
import 'package:ai_community/screens/main_screen.dart';
import 'package:ai_community/services/community_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 네트워크 없이 고정 데이터를 반환하는 가짜 서비스.
class _FakeService extends CommunityService {
  @override
  Future<List<Board>> getBoards() async => const [
        Board(id: 'b1', name: '핫이슈', slug: 'hot-issue', description: ''),
      ];

  @override
  Future<List<Post>> getBestPosts() async => [
        Post(
          id: 'best1',
          boardId: 'b1',
          title: '베스트 글',
          sourceText: '베스트 본문',
          createdAt: DateTime(2026, 9, 28),
          viewCount: 500,
          commentCount: 12,
        ),
      ];

  @override
  Future<List<Post>> getBoardPosts(String boardId,
          {String sort = 'latest', int page = 1}) async =>
      [
        Post(
          id: 'latest1',
          boardId: 'b1',
          title: '가장 최신 글',
          sourceText: '최신 본문',
          createdAt: DateTime(2026, 9, 28),
          viewCount: 5,
          commentCount: 34,
        ),
      ];
}

void main() {
  testWidgets('메인 화면이 게시판별 최신글과 댓글 수를 화면에 출력한다', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MainScreen(service: _FakeService())));
    // 여러 FutureBuilder(베스트/게시판/최신글)가 순차로 완료되도록 정착시킨다.
    await tester.pumpAndSettle();

    // 최신글 섹션 헤더
    expect(find.text('게시판별 최신글'), findsOneWidget);
    // 최신글 본문 제목이 실제로 렌더되는지 (이게 안 나오던 게 핵심 버그)
    expect(find.text('가장 최신 글'), findsOneWidget);
    // 최신글의 댓글 수 34가 화면에 출력되는지
    expect(find.text('34'), findsWidgets);
    // 베스트 섹션도 함께 출력되는지
    expect(find.text('베스트 글'), findsOneWidget);
  });
}
