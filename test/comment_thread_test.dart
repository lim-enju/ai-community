import 'package:ai_community/models/character.dart';
import 'package:ai_community/models/comment.dart';
import 'package:ai_community/widgets/comment_thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Character _char(String id, String name, String archetype) => Character(
      id: id,
      name: name,
      archetype: archetype,
      personality: '',
      avatarColor: Colors.blue,
    );

Comment _comment(String id, String characterId, String content) => Comment(
      id: id,
      postId: 'p1',
      characterId: characterId,
      roundNumber: 1,
      content: content,
      createdAt: DateTime(2026, 9, 28),
    );

void main() {
  test('resolveCharacter: 맵에 있으면 실제 이름, 없으면 mock으로 폴백한다', () {
    final map = {'uuid-1': _char('uuid-1', '진영 프레이머', 'camp')};

    // 실제 캐릭터가 있으면 그 이름으로 해석된다.
    expect(resolveCharacter('uuid-1', map).name, '진영 프레이머');

    // 맵에 없는 UUID는 mock 첫 캐릭터(예언자 노아)로 폴백된다.
    // → 예전엔 모든 실제 댓글이 이 경로로 빠져 전부 '예언자 노아'로 표시되던 버그였다.
    expect(resolveCharacter('unknown-uuid', const {}).name, '예언자 노아');
  });

  testWidgets('CommentThread가 댓글마다 서로 다른 실제 캐릭터 이름을 표시한다', (tester) async {
    final map = {
      'uuid-1': _char('uuid-1', '진영 프레이머', 'camp'),
      'uuid-2': _char('uuid-2', '장문 팩트 교정러', 'fact'),
    };
    final comments = [
      _comment('c1', 'uuid-1', '이건 진영 싸움임'),
      _comment('c2', 'uuid-2', '사실 관계부터 보면'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CommentThread(comments: comments, charactersById: map),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('진영 프레이머'), findsOneWidget);
    expect(find.text('장문 팩트 교정러'), findsOneWidget);
    // 더 이상 모든 댓글이 한 캐릭터로 뭉치지 않는다.
    expect(find.text('예언자 노아'), findsNothing);
  });
}
