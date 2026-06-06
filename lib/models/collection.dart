import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'collection.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Collection {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final List<String> requestIds;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  Collection({
    String? id,
    required this.name,
    this.description,
    List<String>? requestIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        requestIds = requestIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  Collection copyWith({
    String? name,
    String? description,
    List<String>? requestIds,
  }) {
    return Collection(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      requestIds: requestIds ?? this.requestIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
