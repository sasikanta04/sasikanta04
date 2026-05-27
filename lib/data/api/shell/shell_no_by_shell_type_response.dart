// API response model for GET /shellno-by-shelltype
//
// Response shape:
// {
//   "success": true, "status": true, "message": "...",
//   "data": [
//     { "frame_type_id": "...", "frame_type_name": "...",
//       "shell_nos": [
//         { "id": "...", "form_no": "...", "stage": "...",
//           "frame_type_id": "...", "status": 1,
//           "created_at": "...", "updated_at": "..." }
//       ]
//     }
//   ]
// }

class ShellNoByShellTypeResponse {
  final bool?   success;
  final bool?   status;
  final String? message;
  final List<ShellTypeWithNosData> data;

  const ShellNoByShellTypeResponse({
    this.success,
    this.status,
    this.message,
    this.data = const [],
  });

  factory ShellNoByShellTypeResponse.fromJson(Map<String, dynamic> j) =>
      ShellNoByShellTypeResponse(
        success: j['success'] as bool?,
        status:  j['status']  as bool?,
        message: j['message'] as String?,
        data: (j['data'] as List? ?? [])
            .map((e) => ShellTypeWithNosData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Parent — one shell type with its shell numbers ────────────────────────────

class ShellTypeWithNosData {
  final String            frameTypeId;
  final String            frameTypeName;
  final List<ShellNoData> shellNos;

  const ShellTypeWithNosData({
    required this.frameTypeId,
    required this.frameTypeName,
    this.shellNos = const [],
  });

  factory ShellTypeWithNosData.fromJson(Map<String, dynamic> j) =>
      ShellTypeWithNosData(
        frameTypeId:   (j['frame_type_id']   ?? '').toString(),
        frameTypeName: (j['frame_type_name'] ?? '').toString(),
        shellNos: (j['shell_nos'] as List? ?? [])
            .map((e) => ShellNoData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'frame_type_id':   frameTypeId,
        'frame_type_name': frameTypeName,
        'shell_nos':       shellNos.map((e) => e.toJson()).toList(),
      };
}

// ── Child — one shell number entry ────────────────────────────────────────────

class ShellNoData {
  final String  id;
  final String  formNo;
  final String? stage;
  final String  frameTypeId;
  final int?    status;

  const ShellNoData({
    required this.id,
    required this.formNo,
    this.stage,
    required this.frameTypeId,
    this.status,
  });

  factory ShellNoData.fromJson(Map<String, dynamic> j) => ShellNoData(
        id:          (j['id']              ?? '').toString(),
        formNo:      (j['form_no']         ?? '').toString(),
        stage:       j['stage'] as String?,
        frameTypeId: (j['frame_type_id']   ?? '').toString(),
        status:      j['status'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id':            id,
        'form_no':       formNo,
        'stage':         stage,
        'frame_type_id': frameTypeId,
        'status':        status,
      };
}
