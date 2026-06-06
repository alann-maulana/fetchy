import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'api_request.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class ApiRequest {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String method;

  @HiveField(4)
  final Map<String, dynamic>? headers;

  @HiveField(5)
  final Map<String, dynamic>? queryParams;

  @HiveField(6)
  final dynamic body;

  @HiveField(7)
  final String? bodyType; // raw, json, form-data, x-www-form-urlencoded

  @HiveField(8)
  final String? authType; // none, basic, bearer, apikey

  @HiveField(9)
  final Map<String, dynamic>? authData;

  @HiveField(10)
  final String? collectionId;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  ApiRequest({
    String? id,
    required this.name,
    required this.url,
    required this.method,
    this.headers,
    this.queryParams,
    this.body,
    this.bodyType,
    this.authType,
    this.authData,
    this.collectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ApiRequest.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestToJson(this);

  ApiRequest copyWith({
    String? id,
    String? name,
    String? url,
    String? method,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
    String? bodyType,
    String? authType,
    Map<String, dynamic>? authData,
    String? collectionId,
  }) {
    return ApiRequest(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      queryParams: queryParams ?? this.queryParams,
      body: body ?? this.body,
      bodyType: bodyType ?? this.bodyType,
      authType: authType ?? this.authType,
      authData: authData ?? this.authData,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
