import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'environment.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class Environment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final Map<String, String> variables;

  @HiveField(3)
  final bool isActive;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  Environment({
    String? id,
    required this.name,
    Map<String, String>? variables,
    this.isActive = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        variables = variables ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Environment.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentToJson(this);

  Environment copyWith({
    String? name,
    Map<String, String>? variables,
    bool? isActive,
  }) {
    return Environment(
      id: id,
      name: name ?? this.name,
      variables: variables ?? this.variables,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  String resolveVariables(String text) {
    String resolved = text;
    variables.forEach((key, value) {
      resolved = resolved.replaceAll('{{$key}}', value);
    });
    return resolved;
  }
}
