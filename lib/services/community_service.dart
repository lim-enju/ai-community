import '../mock/mock_data.dart';
import '../models/board.dart';
import '../models/character.dart';
import '../models/comment.dart';
import '../models/post.dart';
import 'api_client.dart';

/// Data-access layer for the app. Every method tries the real backend
/// first and transparently falls back to mock data if the request fails
/// (backend not deployed yet, network error, unexpected shape, etc).
class CommunityService {
  CommunityService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

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
      final list = (data as List).map((e) => Post.fromJson(e)).toList();
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
      final data = await _client.get('/characters');
      final list = (data as List).map((e) => Character.fromJson(e)).toList();
      if (list.isEmpty) return MockData.characters;
      return list;
    } catch (_) {
      return MockData.characters;
    }
  }

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
