import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Thin wrapper around [http] that centralizes base URL, timeout and
/// JSON decoding for the whole app.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())),
    );
    final response = await _client.get(uri).timeout(ApiConfig.timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('요청이 실패했습니다 (${response.statusCode})');
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
