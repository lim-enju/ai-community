// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/post.dart';

part 'search_client.g.dart';

@RestApi()
abstract class SearchClient {
  factory SearchClient(Dio dio, {String? baseUrl}) = _SearchClient;

  @GET('/search')
  Future<List<Post>> searchControllerSearch({
    @Query('query') required String query,
    @Query('tag') required String tag,
  });
}
