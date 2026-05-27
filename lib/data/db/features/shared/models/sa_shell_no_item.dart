import 'package:hive/hive.dart';

part 'sa_shell_no_item.g.dart';

// typeId 11 — Shell No Item (child in Shell Type / Shell No parent-child dropdown).
// shellTypeId == frame_type_id of the parent SaShellType.
@HiveType(typeId: 11)
class SaShellNoItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String formNo; // form_no — displayed in the Shell No dropdown

  @HiveField(2)
  final String? stage;

  @HiveField(3)
  final String shellTypeId; // frame_type_id — parent reference

  @HiveField(4)
  final int? status;

  SaShellNoItem({
    required this.id,
    required this.formNo,
    this.stage,
    required this.shellTypeId,
    this.status,
  });

  factory SaShellNoItem.fromJson(Map<String, dynamic> j) => SaShellNoItem(
        id:          (j['id']            ?? '').toString(),
        formNo:      (j['form_no']       ?? '').toString(),
        stage:       j['stage'] as String?,
        shellTypeId: (j['shell_type_id'] ?? '').toString(),
        status:      j['status'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id':            id,
        'form_no':       formNo,
        'stage':         stage,
        'shell_type_id': shellTypeId,
        'status':        status,
      };
}
