import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/models/character.dart' as api;
import '../api/rest_client.dart';
import '../mock/mock_data.dart';
import '../models/agent_interaction.dart';
import '../models/board.dart';
import '../models/character.dart';
import '../models/comment.dart';
import '../models/interest_overview.dart';
import '../models/post.dart';
import '../models/post_interest.dart';
import 'api_client.dart';
import 'api_config.dart';

/// Data-access layer for the app. Every method tries the real backend
/// first and transparently falls back to mock data if the request fails
/// (backend not deployed yet, network error, unexpected shape, etc).
class CommunityService {
  CommunityService({ApiClient? client, RestClient? rest})
      : _client = client ?? ApiClient(),
        _rest = rest ?? RestClient(Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)));

  final ApiClient _client;

  /// openapi.json에서 생성된 타입드 클라이언트(retrofit). 캐릭터 조회에 사용한다.
  final RestClient _rest;

  Future<List<Board>> getBoards() async {
    try {
      final data = await _client.get('/boards');
      final list = (data as List).map((e) => Board.fromJson(e)).toList();
      if (list.isEmpty) return MockData.boards;
      return list;
    } catch (_) {
      return MockData.boards;
    }
  }

  Future<List<Post>> getBoardPosts(
    String boardId, {
    String sort = 'latest',
    int page = 1,
  }) async {
    try {
      final data = await _client.get(
        '/boards/$boardId/posts',
        query: {'sort': sort, 'page': page},
      );
      // 백엔드는 페이지네이션 객체 {items, total, page, limit}를 반환한다.
      // (베스트 등 일부 경로는 배열을 그대로 반환하므로 두 형태를 모두 허용한다.)
      final rawList = data is List ? data : (data is Map ? (data['items'] as List? ?? const []) : const []);
      final list = rawList.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isEmpty) return _sortMock(MockData.postsByBoard(boardId), sort);
      return list;
    } catch (_) {
      return _sortMock(MockData.postsByBoard(boardId), sort);
    }
  }

  Future<List<Post>> getBestPosts() async {
    try {
      final data = await _client.get('/boards/best');
      final list = (data as List).map((e) => Post.fromJson(e)).toList();
      if (list.isEmpty) return MockData.bestPosts();
      return list;
    } catch (_) {
      return MockData.bestPosts();
    }
  }

  Future<Post> getPost(String postId) async {
    try {
      final data = await _client.get('/posts/$postId');
      return Post.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return MockData.posts.firstWhere(
        (p) => p.id == postId,
        orElse: () => MockData.posts.first,
      );
    }
  }

  Future<List<Comment>> getComments(String postId) async {
    try {
      final data = await _client.get('/posts/$postId/comments');
      final list = (data as List).map((e) => Comment.fromJson(e)).toList();
      if (list.isEmpty) return MockData.commentsFor(postId);
      return list;
    } catch (_) {
      return MockData.commentsFor(postId);
    }
  }

  Future<List<Character>> getCharacters() async {
    try {
      // 생성된 retrofit 클라이언트로 호출·파싱 → 앱 모델로 매핑.
      final list = await _rest.characters.charactersControllerFindAll();
      if (list.isEmpty) return MockData.characters;
      return list.map(_characterFromApi).toList();
    } catch (_) {
      return MockData.characters;
    }
  }

  /// 생성 모델(api.Character) → 앱 UI 모델(Character) 변환.
  /// API엔 avatarColor가 없으므로 이름 해시로 안정적인 색을 만든다.
  Character _characterFromApi(api.Character c) => Character(
        id: c.id,
        name: c.name,
        archetype: c.archetype.json ?? '',
        speechExamples: c.speechExamples,
        personality: c.personality,
        avatarColor: Color(0xFF000000 | (c.name.hashCode & 0x00FFFFFF)),
      );

  Future<Character> getCharacter(String characterId) async {
    try {
      final data = await _client.get('/characters/$characterId');
      return Character.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return MockData.characterById(characterId);
    }
  }

  Future<List<Post>> getCharacterPosts(String characterId) async {
    // No dedicated endpoint is specified for this; approximate using mock
    // comments to find posts a character has participated in, with a
    // best-effort attempt against the generic post list first.
    try {
      final boards = await getBoards();
      final all = <Post>[];
      for (final board in boards) {
        all.addAll(await getBoardPosts(board.id));
      }
      final participated = <Post>[];
      for (final post in all) {
        final comments = await getComments(post.id);
        if (comments.any((c) => c.characterId == characterId)) {
          participated.add(post);
        }
      }
      if (participated.isNotEmpty) return participated;
    } catch (_) {
      // fall through to mock
    }
    return MockData.posts
        .where((p) => MockData.commentsFor(p.id)
            .any((c) => c.characterId == characterId))
        .toList();
  }

  /// Agents that viewed / showed interest in a post (commented or lurked).
  Future<List<PostInterest>> getPostInterests(String postId) async {
    try {
      final data = await _client.get('/posts/$postId/interests');
      final list = (data as List).map((e) => PostInterest.fromJson(e)).toList();
      if (list.isEmpty) return MockData.interestsFor(postId);
      return list;
    } catch (_) {
      return MockData.interestsFor(postId);
    }
  }

  /// Posts a given agent viewed / showed interest in.
  Future<List<CharacterInterest>> getCharacterInterests(String characterId) async {
    try {
      final data = await _client.get('/characters/$characterId/interests');
      final list = (data as List).map((e) => CharacterInterest.fromJson(e)).toList();
      if (list.isEmpty) return MockData.characterInterestsFor(characterId);
      return list;
    } catch (_) {
      return MockData.characterInterestsFor(characterId);
    }
  }

  /// Who replied to whom, most frequent pairs first.
  Future<List<AgentInteraction>> getAgentInteractions() async {
    try {
      final data = await _client.get('/analytics/agent-interactions');
      final list = (data as List).map((e) => AgentInteraction.fromJson(e)).toList();
      if (list.isEmpty) return MockData.agentInteractions();
      return list;
    } catch (_) {
      return MockData.agentInteractions();
    }
  }

  /// Aggregated interest statistics (per-agent views + most-viewed posts).
  Future<InterestOverview> getInterestOverview() async {
    try {
      final data = await _client.get('/analytics/interest-overview');
      return InterestOverview.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return MockData.interestOverview();
    }
  }

  Future<List<Post>> search({String? query, String? tag}) async {
    try {
      final data = await _client.get('/search', query: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (tag != null && tag.isNotEmpty) 'tag': tag,
      });
      final list = (data as List).map((e) => Post.fromJson(e)).toList();
      return list;
    } catch (_) {
      return MockData.posts.where((p) {
        final matchesQuery = query == null ||
            query.isEmpty ||
            p.title.contains(query) ||
            p.sourceText.contains(query);
        final matchesTag = tag == null || tag.isEmpty || p.tags.contains(tag);
        return matchesQuery && matchesTag;
      }).toList();
    }
  }

  List<Post> _sortMock(List<Post> posts, String sort) {
    final copy = [...posts];
    if (sort == 'popular') {
      copy.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    } else {
      copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return copy;
  }
}
