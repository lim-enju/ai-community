// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/comment.dart';
import '../models/post.dart';

part 'posts_client.g.dart';

@RestApi()
abstract class PostsClient {
  factory PostsClient(Dio dio, {String? baseUrl}) = _PostsClient;

  @GET('/posts/{postId}')
  Future<Post> postsControllerFindOne({
    @Path('postId') required String postId,
  });

  @GET('/posts/{postId}/comments')
  Future<List<Comment>> postsControllerFindComments({
    @Path('postId') required String postId,
  });
}
