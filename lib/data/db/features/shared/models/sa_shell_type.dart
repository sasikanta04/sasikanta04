import 'package:hive/hive.dart';

part 'sa_shell_type.g.dart';

// typeId 10 — Shell Type (parent in Shell Type / Shell No parent-child dropdown).
// typeId range 0–9 is reserved for other shared masters (frame type, makes, etc.).
@HiveType(typeId: 10)
class SaShellType extends HiveObject {
  @HiveField(0)
  final String id; // frame_type_id

  @HiveField(1)
  final String name; // frame_type_name

  SaShellType({
    required this.id,
    required this.name,
  });

  factory SaShellType.fromJson(Map<String, dynamic> j) => SaShellType(
        id:   (j['id']   ?? '').toString(),
        name: (j['name'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
