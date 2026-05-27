class SaShellType {
  final String id;
  final String title;
  final String code;

  const SaShellType({
    required this.id,
    required this.title,
    required this.code,
  });

  factory SaShellType.fromJson(Map<String, dynamic> j) => SaShellType(
        id:    (j['id']    ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        code:  (j['code']  ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'code': code};
}
