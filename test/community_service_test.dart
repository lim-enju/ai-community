import 'dart:convert';

import 'package:ai_community/models/post.dart';
import 'package:ai_community/services/api_client.dart';
import 'package:ai_community/services/community_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// 지정한 JSON 본문을 항상 반환하는 가짜 HTTP 클라이언트로 CommunityService를 만든다.
CommunityService serviceReturning(Object jsonBody) {
  final mock = MockClient(
    (req) async => http.Response(
      jsonEncode(jsonBody),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    ),
  );
  return CommunityService(client: ApiClient(client: mock));
}

void main() {
  test('getBoardPosts가 {items:[...]} 페이지네이션 응답을 파싱하고 commentCount를 읽는다', () async {
    // 백엔드 실제 응답 형태. 과거엔 이 형태를 List로 캐스팅하다 실패해
    // mock으로 폴백 → "최신글이 안 나오는" 버그였다.
    final service = serviceReturning({
      'items': [
        {
          'id': '1',
          'boardId': 'b',
          'sourceText': '첫 번째 글',
          'tags': <String>[],
          'viewCount': 10,
          'createdAt': '2026-09-28T00:00:00.000Z',
          'commentCount': 5,
        },
        {
          'id': '2',
          'boardId': 'b',
          'sourceText': '두 번째 글',
          'tags': <String>[],
          'viewCount': 3,
          'createdAt': '2026-09-27T00:00:00.000Z',
          'commentCount': 0,
        },
      ],
      'total': 2,
      'page': 1,
      'limit': 20,
    });

    final posts = await service.getBoardPosts('hot-issue');

    expect(posts.length, 2, reason: 'items 배열의 글 2개가 파싱되어야 한다');
    expect(posts.first.title, '첫 번째 글');
    expect(posts.first.commentCount, 5, reason: 'commentCount가 응답에서 읽혀야 한다');
  });

  test('getBoardPosts가 배열(List) 형태 응답도 허용한다', () async {
    final service = serviceReturning([
      {
        'id': '1',
        'boardId': 'b',
        'sourceText': '글',
        'tags': <String>[],
        'viewCount': 1,
        'createdAt': '2026-09-28T00:00:00.000Z',
        'commentCount': 7,
      },
    ]);

    final posts = await service.getBoardPosts('x');

    expect(posts.single.commentCount, 7);
  });

  test('Post.fromJson이 commentCount를 읽고, title이 없으면 본문 첫 줄로 대체한다', () {
    // 백엔드는 title 컬럼이 없어 sourceText 첫 줄이 제목이 된다.
    final post = Post.fromJson({
      'id': '1',
      'boardId': 'b',
      'sourceText': '제목이 될 첫 줄\n둘째 줄은 본문',
      'tags': <String>[],
      'viewCount': 2,
      'createdAt': '2026-09-28T00:00:00.000Z',
      'commentCount': 9,
    });

    expect(post.commentCount, 9);
    expect(post.title, '제목이 될 첫 줄');
  });
}
