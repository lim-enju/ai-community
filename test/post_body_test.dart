import 'package:ai_community/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

Post make(String sourceText) => Post(
      id: '1',
      boardId: 'b',
      title: sourceText.split('\n').first,
      sourceText: sourceText,
      createdAt: DateTime(2026),
    );

void main() {
  test('body는 제목(첫 줄)을 제거해 카드/상세 중복을 막는다', () {
    final p = make('제목 한 줄\n본문 첫째 줄\n본문 둘째 줄');
    expect(p.title, '제목 한 줄');
    expect(p.body, '본문 첫째 줄\n본문 둘째 줄');
  });

  test('단일 줄 글이면 body는 빈 문자열(중복 없음)', () {
    final p = make('제목만 있는 글');
    expect(p.body, '');
  });

  test('제목이 본문 첫 줄과 다르면(백엔드가 별도 title 제공) 본문 전체 유지', () {
    final p = Post(
      id: '1',
      boardId: 'b',
      title: '실제 제목',
      sourceText: '전혀 다른 본문입니다',
      createdAt: DateTime(2026),
    );
    expect(p.body, '전혀 다른 본문입니다');
  });
}
