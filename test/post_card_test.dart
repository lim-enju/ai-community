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
