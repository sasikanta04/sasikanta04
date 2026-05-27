// Shell number model — shellTypeId is the parent reference for the
// parent-child relationship between Shell Type and Shell No dropdowns.

class SaShellNoItem {
  final String  id;
  final String  shellNo;
  final String  shellTypeId;
  final String? date;

  const SaShellNoItem({
    required this.id,
    required this.shellNo,
    required this.shellTypeId,
    this.date,
  });

  factory SaShellNoItem.fromJson(Map<String, dynamic> j) => SaShellNoItem(
        id:          (j['id']            ?? '').toString(),
        shellNo:     (j['shell_no']      ?? '').toString(),
        shellTypeId: (j['shell_type_id'] ?? '').toString(),
        date:        j['date'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':            id,
        'shell_no':      shellNo,
        'shell_type_id': shellTypeId,
        'date':          date,
      };
}
