import 'package:ai_community/models/post.dart';
import 'package:ai_community/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 게시글 카드가 "댓글 수"와 "조회수"를 실제 화면에 출력하는지 검증한다.
/// (댓글 수가 0으로만 나오던 버그가 프론트가 아니라 백엔드 응답 누락이었음을
///  이 테스트가 못박는다 — 데이터가 주어지면 UI는 정상적으로 그린다.)
void main() {
  testWidgets('PostCard가 댓글 수와 조회수를 화면에 출력한다', (tester) async {
    final post = Post(
      id: 'p1',
      boardId: 'b1',
      title: '테스트 글 제목',
      sourceText: '본문 내용',
      createdAt: DateTime(2026, 9, 28),
      viewCount: 99,
      commentCount: 42,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: PostCard(post: post))),
    );

    expect(find.text('테스트 글 제목'), findsOneWidget);
    expect(find.text('42'), findsOneWidget, reason: '댓글 수 42가 화면에 보여야 한다');
    expect(find.text('99'), findsOneWidget, reason: '조회수 99가 화면에 보여야 한다');
    // 댓글 아이콘도 함께 렌더되는지 확인
    expect(find.byIcon(Icons.forum_outlined), findsOneWidget);
  });

  // 실제 응답엔 title 필드가 없어 제목을 sourceText 첫 줄로 유도한다.
  // 단일 줄 글에서 본문이 사라지던 회귀를 이 두 테스트가 못박는다.
  testWidgets('단일 줄 글도 카드에 글 내용이 보인다 (내용 사라짐 방지)', (tester) async {
    final post = Post.fromJson({
      'id': 'p1',
      'boardId': 'b1',
      'sourceText': 'AI 규제를 두고 두 진영이 붙었다',
      'createdAt': '2026-09-28T00:00:00.000Z',
    });

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: PostCard(post: post))),
    );

    expect(find.textContaining('AI 규제를 두고'), findsWidgets,
        reason: '단일 줄 글도 내용이 화면에 보여야 한다');
  });

  testWidgets('여러 줄 글은 제목(첫 줄)과 본문(나머지)이 중복 없이 보인다', (tester) async {
    final post = Post.fromJson({
      'id': 'p2',
      'boardId': 'b1',
      'sourceText': '제목이 되는 첫 줄\n본문이 되는 둘째 줄',
      'createdAt': '2026-09-28T00:00:00.000Z',
    });

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: PostCard(post: post))),
    );

    expect(find.text('제목이 되는 첫 줄'), findsOneWidget);
    expect(find.text('본문이 되는 둘째 줄'), findsOneWidget);
  });

  testWidgets('댓글이 없으면 댓글 수가 0으로 출력된다', (tester) async {
    final post = Post(
      id: 'p2',
      boardId: 'b1',
      title: '댓글 없는 글',
      sourceText: '본문',
      createdAt: DateTime(2026, 9, 28),
      viewCount: 0,
      commentCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: PostCard(post: post))),
    );

    // 조회수 0, 댓글 수 0 → '0' 텍스트가 2개
    expect(find.text('0'), findsNWidgets(2));
  });
}
