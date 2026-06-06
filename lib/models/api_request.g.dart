// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApiRequestAdapter extends TypeAdapter<ApiRequest> {
  @override
  final int typeId = 0;

  @override
  ApiRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApiRequest(
      id: fields[0] as String?,
      name: fields[1] as String,
      url: fields[2] as String,
      method: fields[3] as String,
      headers: (fields[4] as Map?)?.cast<String, dynamic>(),
      queryParams: (fields[5] as Map?)?.cast<String, dynamic>(),
      body: fields[6] as dynamic,
      bodyType: fields[7] as String?,
      authType: fields[8] as String?,
      authData: (fields[9] as Map?)?.cast<String, dynamic>(),
      collectionId: fields[10] as String?,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ApiRequest obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.method)
      ..writeByte(4)
      ..write(obj.headers)
      ..writeByte(5)
      ..write(obj.queryParams)
      ..writeByte(6)
      ..write(obj.body)
      ..writeByte(7)
      ..write(obj.bodyType)
      ..writeByte(8)
      ..write(obj.authType)
      ..writeByte(9)
      ..write(obj.authData)
      ..writeByte(10)
      ..write(obj.collectionId)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiRequest _$ApiRequestFromJson(Map<String, dynamic> json) => ApiRequest(
      id: json['id'] as String?,
      name: json['name'] as String,
      url: json['url'] as String,
      method: json['method'] as String,
      headers: json['headers'] as Map<String, dynamic>?,
      queryParams: json['queryParams'] as Map<String, dynamic>?,
      body: json['body'],
      bodyType: json['bodyType'] as String?,
      authType: json['authType'] as String?,
      authData: json['authData'] as Map<String, dynamic>?,
      collectionId: json['collectionId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ApiRequestToJson(ApiRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'method': instance.method,
      'headers': instance.headers,
      'queryParams': instance.queryParams,
      'body': instance.body,
      'bodyType': instance.bodyType,
      'authType': instance.authType,
      'authData': instance.authData,
      'collectionId': instance.collectionId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
