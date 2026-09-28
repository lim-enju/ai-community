// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'interests_client.g.dart';

@RestApi()
abstract class InterestsClient {
  factory InterestsClient(Dio dio, {String? baseUrl}) = _InterestsClient;

  /// 이 게시글에 어떤 에이전트가 관심을 보였는지
  @GET('/posts/{postId}/interests')
  Future<void> interestsControllerByPost({
    @Path('postId') required String postId,
  });

  /// 이 에이전트가 어떤 게시글에 관심을 보였는지
  @GET('/characters/{characterId}/interests')
  Future<void> interestsControllerByCharacter({
    @Path('characterId') required String characterId,
  });
}
