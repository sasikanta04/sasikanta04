import 'package:hive_flutter/hive_flutter.dart';

import '../../../api/shell/shell_no_by_shell_type_response.dart';
import '../models/sa_shell_no.dart';

/// Shared master for Shell Type and Shell No dropdown data.
///
/// Uses a single SaShellNo Hive box.  Each record is one shell_nos entry;
/// frame_type_name is denormalised into every row so the Shell Type list
/// can be derived from the same box without a second adapter.
///
/// Register the adapter before calling init():
///   Hive.registerAdapter(SaShellNoAdapter());  // typeId 10
class SaShellTypeShellNoService {
  static const _boxName = 'sa_shell_no_box';

  Box<SaShellNo> get _box => Hive.box<SaShellNo>(_boxName);

  Future<void> init() async {
    await Hive.openBox<SaShellNo>(_boxName);
  }

  Future<void> saveAll(List<ShellTypeWithNosData> items) async {
    await _box.clear();
    for (final type in items) {
      for (final sn in type.shellNos) {
        await _box.put(
          sn.id,
          SaShellNo(
            id:            sn.id,
            formNo:        sn.formNo,
            stage:         sn.stage,
            frameTypeId:   type.frameTypeId,
            frameTypeName: type.frameTypeName,
            status:        sn.status,
          ),
        );
      }
    }
  }

  Future<void> clearAll() => _box.clear();

  /// Distinct shell types derived from stored records, preserving API order.
  List<({String id, String name})> getShellTypes() {
    final seen  = <String>{};
    final types = <({String id, String name})>[];
    for (final sn in _box.values) {
      if (seen.add(sn.frameTypeId)) {
        types.add((id: sn.frameTypeId, name: sn.frameTypeName));
      }
    }
    return types;
  }

  /// Shell numbers belonging to the given [shellTypeId] (frame_type_id).
  List<SaShellNo> getShellNosByShellTypeId(String shellTypeId) =>
      _box.values.where((e) => e.frameTypeId == shellTypeId).toList();
}
