import 'package:hive/hive.dart';

part 'sa_shell_no.g.dart';

@HiveType(typeId: 10)
class SaShellNo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String formNo; // form_no — displayed in Shell No dropdown

  @HiveField(2)
  String? stage;

  @HiveField(3)
  String frameTypeId; // frame_type_id — parent key

  @HiveField(4)
  String frameTypeName; // frame_type_name — denormalised for Shell Type dropdown

  @HiveField(5)
  int status;

  SaShellNo({
    required this.id,
    required this.formNo,
    this.stage,
    required this.frameTypeId,
    required this.frameTypeName,
    required this.status,
  });

  factory SaShellNo.fromJson(Map<String, dynamic> json) {
    return SaShellNo(
      id:            (json['id']              ?? '').toString(),
      formNo:        (json['form_no']         ?? '').toString(),
      stage:         json['stage'] as String?,
      frameTypeId:   (json['frame_type_id']   ?? '').toString(),
      frameTypeName: (json['frame_type_name'] ?? '').toString(),
      status:        (json['status'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':              id,
      'form_no':         formNo,
      'stage':           stage,
      'frame_type_id':   frameTypeId,
      'frame_type_name': frameTypeName,
      'status':          status,
    };
  }

  SaShellNo copyWith({
    String? id,
    String? formNo,
    String? stage,
    String? frameTypeId,
    String? frameTypeName,
    int? status,
  }) {
    return SaShellNo(
      id:            id            ?? this.id,
      formNo:        formNo        ?? this.formNo,
      stage:         stage         ?? this.stage,
      frameTypeId:   frameTypeId   ?? this.frameTypeId,
      frameTypeName: frameTypeName ?? this.frameTypeName,
      status:        status        ?? this.status,
    );
  }
}
