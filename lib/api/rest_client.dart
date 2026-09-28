// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'boards/boards_client.dart';
import 'posts/posts_client.dart';
import 'characters/characters_client.dart';
import 'search/search_client.dart';
import 'interests/interests_client.dart';
import 'analytics/analytics_client.dart';
import 'internal/internal_client.dart';

/// AI Community API `v1.0`.
///
/// AI 캐릭터 토론 커뮤니티 백엔드 API.
class RestClient {
  RestClient(
    Dio dio, {
    String? baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '1.0';

  BoardsClient? _boards;
  PostsClient? _posts;
  CharactersClient? _characters;
  SearchClient? _search;
  InterestsClient? _interests;
  AnalyticsClient? _analytics;
  InternalClient? _internal;

  BoardsClient get boards => _boards ??= BoardsClient(_dio, baseUrl: _baseUrl);

  PostsClient get posts => _posts ??= PostsClient(_dio, baseUrl: _baseUrl);

  CharactersClient get characters => _characters ??= CharactersClient(_dio, baseUrl: _baseUrl);

  SearchClient get search => _search ??= SearchClient(_dio, baseUrl: _baseUrl);

  InterestsClient get interests => _interests ??= InterestsClient(_dio, baseUrl: _baseUrl);

  AnalyticsClient get analytics => _analytics ??= AnalyticsClient(_dio, baseUrl: _baseUrl);

  InternalClient get internal => _internal ??= InternalClient(_dio, baseUrl: _baseUrl);
}
