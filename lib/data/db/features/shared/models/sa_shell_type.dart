// Hive-backed model for a Shell Type (parent in the parent-child dropdown).
// Maps to frame_type_id / frame_type_name from /shellno-by-shelltype.

class SaShellType {
  final String id;   // frame_type_id
  final String name; // frame_type_name

  const SaShellType({
    required this.id,
    required this.name,
  });

  factory SaShellType.fromJson(Map<String, dynamic> j) => SaShellType(
        id:   (j['id']   ?? '').toString(),
        name: (j['name'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
