// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/board.dart';
import '../models/post.dart';

part 'boards_client.g.dart';

@RestApi()
abstract class BoardsClient {
  factory BoardsClient(Dio dio, {String? baseUrl}) = _BoardsClient;

  @GET('/boards')
  Future<List<Board>> boardsControllerFindAll();

  @GET('/boards/best')
  Future<List<Post>> boardsControllerFindBest({
    @Query('limit') required num limit,
  });

  @GET('/boards/{boardId}/posts')
  Future<void> boardsControllerFindPosts({
    @Path('boardId') required String boardId,
    @Query('sort') required String sort,
    @Query('page') required num page,
  });
}
