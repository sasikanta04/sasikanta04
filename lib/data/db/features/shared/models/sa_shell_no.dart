import 'package:hive/hive.dart';

part 'sa_shell_no.g.dart';

// Single Hive model for the /shellno-by-shelltype response.
// Each record is one shell_nos entry; frame_type_name is denormalised into the
// row so the Shell Type dropdown can be derived from the same box without a
// second adapter.
//
// typeId: 10  — confirm with senior if other shared adapters use this range.
@HiveType(typeId: 10)
class SaShellNo extends HiveObject {
  @HiveField(0)
  String id; // shell_nos[].id

  @HiveField(1)
  String formNo; // shell_nos[].form_no  — displayed in Shell No dropdown

  @HiveField(2)
  String? stage; // shell_nos[].stage

  @HiveField(3)
  String frameTypeId; // shell_nos[].frame_type_id  — parent key

  @HiveField(4)
  String frameTypeName; // parent frame_type_name — denormalised for Shell Type dropdown

  @HiveField(5)
  int? status;

  SaShellNo({
    required this.id,
    required this.formNo,
    this.stage,
    required this.frameTypeId,
    required this.frameTypeName,
    this.status,
  });
}
