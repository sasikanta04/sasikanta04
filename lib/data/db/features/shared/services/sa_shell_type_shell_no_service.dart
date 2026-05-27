import '../../../../../core/base_hive_service.dart';
import '../../../../../core/hive_boxes.dart';
import '../../../../../core/hive_keys.dart';
import '../../../../../data/api/shell/shell_no_by_shell_type_response.dart';
import '../models/sa_shell_no.dart';

class SaShellTypeShellNoService extends BaseHiveService<List<SaShellNo>> {
  SaShellTypeShellNoService() : super(HiveBoxes.sharedMasters);

  List<SaShellNo> getShellNos() {
    return getTypedList<SaShellNo>(HiveKeys.shellNoByShellType);
  }

  /// Distinct shell types derived from stored records, preserving API order.
  List<SaShellNo> getShellTypes() {
    final seen  = <String>{};
    final types = <SaShellNo>[];
    for (final sn in getShellNos()) {
      if (seen.add(sn.frameTypeId)) {
        types.add(sn);
      }
    }
    return types;
  }

  /// Shell numbers belonging to the given [shellTypeId] (frame_type_id).
  List<SaShellNo> getShellNosByShellTypeId(String shellTypeId) {
    return getShellNos()
        .where((sn) => sn.frameTypeId == shellTypeId)
        .toList();
  }

  Future<void> saveAll(List<ShellTypeWithNosData> items) async {
    final shellNos = <SaShellNo>[];
    for (final type in items) {
      for (final sn in type.shellNos) {
        shellNos.add(SaShellNo(
          id:            sn.id,
          formNo:        sn.formNo,
          stage:         sn.stage,
          frameTypeId:   type.frameTypeId,
          frameTypeName: type.frameTypeName,
          status:        sn.status ?? 1,
        ));
      }
    }
    await put(HiveKeys.shellNoByShellType, shellNos);
  }

  Future<void> clearAll() async {
    await delete(HiveKeys.shellNoByShellType);
  }
}
