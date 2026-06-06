import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable()
class ApiResponse {
  final int statusCode;
  final String statusMessage;
  final Map<String, dynamic> headers;
  final dynamic body;
  final String? contentType;
  final int responseTime; // in milliseconds
  final DateTime timestamp;

  ApiResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.headers,
    required this.body,
    this.contentType,
    required this.responseTime,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  bool get isJson =>
      contentType?.toLowerCase().contains('application/json') ?? false;

  bool get isHtml => contentType?.toLowerCase().contains('text/html') ?? false;

  bool get isText => contentType?.toLowerCase().contains('text/') ?? false;
}
