// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectionAdapter extends TypeAdapter<Collection> {
  @override
  final int typeId = 1;

  @override
  Collection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Collection(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String?,
      requestIds: (fields[3] as List?)?.cast<String>(),
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Collection obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.requestIds)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Collection _$CollectionFromJson(Map<String, dynamic> json) => Collection(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      requestIds: (json['requestIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CollectionToJson(Collection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'requestIds': instance.requestIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
