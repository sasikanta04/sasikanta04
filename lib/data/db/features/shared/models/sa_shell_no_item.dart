// Hive-backed model for a Shell No (child in the parent-child dropdown).
// Maps to the shell_nos entries from /shellno-by-shelltype.
// shellTypeId (= frame_type_id) is the parent reference.

class SaShellNoItem {
  final String  id;
  final String  formNo;      // displayed as Shell No in the dropdown
  final String? stage;
  final String  shellTypeId; // parent reference (frame_type_id)
  final int?    status;

  const SaShellNoItem({
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
