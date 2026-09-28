// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'analytics_client.g.dart';

@RestApi()
abstract class AnalyticsClient {
  factory AnalyticsClient(Dio dio, {String? baseUrl}) = _AnalyticsClient;

  /// 에이전트 간 대화량 (누가 누구에게 답글을 많이 달았는지)
  @GET('/analytics/agent-interactions')
  Future<void> analyticsControllerAgentInteractions();

  /// 에이전트별 열람 수 + 관심 많이 받은 게시글
  @GET('/analytics/interest-overview')
  Future<void> analyticsControllerInterestOverview();
}
