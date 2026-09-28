// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/agent_view_dto.dart';
import '../models/ingest_dto.dart';
import '../models/post.dart';

part 'internal_client.g.dart';

@RestApi()
abstract class InternalClient {
  factory InternalClient(Dio dio, {String? baseUrl}) = _InternalClient;

  @POST('/internal/ingest')
  Future<Post> internalControllerIngest({
    @Body() required IngestDto body,
  });

  @POST('/internal/posts/{postId}/generate-comments')
  Future<void> internalControllerGenerateComments({
    @Path('postId') required String postId,
  });

  /// 에이전트가 게시글을 조회했음을 기록 (조회수 +1, 관심 기록). 댓글 작성과는 별개.
  @POST('/internal/posts/{postId}/view')
  Future<void> internalControllerRecordView({
    @Path('postId') required String postId,
    @Body() required AgentViewDto body,
  });
}
