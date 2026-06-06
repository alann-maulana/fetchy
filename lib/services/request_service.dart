import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import 'http_client.dart';

class RequestService {
  final HttpClientService _httpClient;

  RequestService(this._httpClient);

  Future<ApiResponse> executeRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    String? bodyType,
    String? authType,
    Map<String, dynamic>? authData,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      dynamic processedBody;
      final allHeaders = Map<String, dynamic>.from(headers ?? {});

      if (bodyType == 'json') {
        allHeaders['Content-Type'] = 'application/json';
        processedBody = body;
      } else if (bodyType == 'form-data' && body is Map) {
        processedBody = FormData.fromMap(body.cast<String, dynamic>());
      } else if (bodyType == 'x-www-form-urlencoded' && body is Map) {
        allHeaders['Content-Type'] = 'application/x-www-form-urlencoded';
        processedBody = body;
      } else if (bodyType == 'raw') {
        processedBody = body;
      } else {
        processedBody = body;
      }

      if (authType == 'basic' && authData != null) {
        final username = authData['username'] ?? '';
        final password = authData['password'] ?? '';
        final basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
        allHeaders['Authorization'] = basicAuth;
      } else if (authType == 'bearer' && authData != null) {
        allHeaders['Authorization'] = 'Bearer ${authData['token']}';
      } else if (authType == 'apikey' && authData != null) {
        final key = authData['key'] ?? '';
        final value = authData['value'] ?? '';
        final addTo = authData['addTo'] ?? 'header';
        if (addTo == 'query') {
          queryParameters ??= <String, dynamic>{};
          queryParameters[key] = value;
        } else {
          allHeaders[key] = value;
        }
      }

      final response = await _httpClient.sendRequest(
        url: url,
        method: method,
        headers: allHeaders.isNotEmpty ? allHeaders : null,
        queryParameters:
            queryParameters?.isNotEmpty == true ? queryParameters : null,
        body: processedBody,
      );

      stopwatch.stop();

      final contentType = response.headers.value('content-type');

      dynamic responseBody;
      if (response.data is Map || response.data is List) {
        responseBody = jsonEncode(response.data);
      } else {
        responseBody = response.data?.toString() ?? '';
      }

      return ApiResponse(
        statusCode: response.statusCode ?? 0,
        statusMessage: response.statusMessage ?? '',
        headers: response.headers.map
            .map((k, v) => MapEntry(k, v.join(', '))),
        body: responseBody,
        contentType: contentType,
        responseTime: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }
}
