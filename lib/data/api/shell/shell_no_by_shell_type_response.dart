// API response model for GET /shellno-by-shelltype
// Returns shell types (parent) each with their shell numbers (children).

class ShellNoByShellTypeResponse {
  final bool?   status;
  final String? message;
  final List<ShellTypeData> data;

  const ShellNoByShellTypeResponse({
    this.status,
    this.message,
    this.data = const [],
  });

  factory ShellNoByShellTypeResponse.fromJson(Map<String, dynamic> j) =>
      ShellNoByShellTypeResponse(
        status:  j['status']  as bool?,
        message: j['message'] as String?,
        data: (j['data'] as List? ?? [])
            .map((e) => ShellTypeData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ShellTypeData {
  final String id;
  final String title;
  final String code;
  final List<ShellNoData> shellNos;

  const ShellTypeData({
    required this.id,
    required this.title,
    required this.code,
    this.shellNos = const [],
  });

  factory ShellTypeData.fromJson(Map<String, dynamic> j) => ShellTypeData(
        id:       (j['id']    ?? '').toString(),
        title:    (j['title'] ?? '').toString(),
        code:     (j['code']  ?? '').toString(),
        shellNos: (j['shell_no'] as List? ?? [])
            .map((e) => ShellNoData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id':       id,
        'title':    title,
        'code':     code,
        'shell_no': shellNos.map((e) => e.toJson()).toList(),
      };
}

class ShellNoData {
  final String  id;
  final String  shellNo;
  final String? date;

  const ShellNoData({
    required this.id,
    required this.shellNo,
    this.date,
  });

  factory ShellNoData.fromJson(Map<String, dynamic> j) => ShellNoData(
        id:      (j['id']       ?? '').toString(),
        shellNo: (j['shell_no'] ?? '').toString(),
        date:    j['date'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':       id,
        'shell_no': shellNo,
        'date':     date,
      };
}
