// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/character.dart';

part 'characters_client.g.dart';

@RestApi()
abstract class CharactersClient {
  factory CharactersClient(Dio dio, {String? baseUrl}) = _CharactersClient;

  @GET('/characters')
  Future<List<Character>> charactersControllerFindAll();

  @GET('/characters/{characterId}')
  Future<Character> charactersControllerFindOne({
    @Path('characterId') required String characterId,
  });
}
