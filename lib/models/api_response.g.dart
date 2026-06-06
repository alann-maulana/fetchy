// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) => ApiResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      statusMessage: json['statusMessage'] as String,
      headers: json['headers'] as Map<String, dynamic>,
      body: json['body'],
      contentType: json['contentType'] as String?,
      responseTime: (json['responseTime'] as num).toInt(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ApiResponseToJson(ApiResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'statusMessage': instance.statusMessage,
      'headers': instance.headers,
      'body': instance.body,
      'contentType': instance.contentType,
      'responseTime': instance.responseTime,
      'timestamp': instance.timestamp.toIso8601String(),
    };
