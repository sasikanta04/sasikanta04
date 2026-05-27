import 'package:hive_flutter/hive_flutter.dart';

import '../../../api/shell/shell_no_by_shell_type_response.dart';
import '../models/sa_shell_no_item.dart';
import '../models/sa_shell_type.dart';

/// Shared master for Shell Type and Shell No dropdown data.
///
/// Fetched from /shellno-by-shelltype and persisted in typed Hive boxes.
/// Kept separate from the dashboard controller's shared master calls.
/// Provides filtered getters for the parent-child dropdown relationship.
///
/// Register adapters before calling init():
///   Hive.registerAdapter(SaShellTypeAdapter());    // typeId 10
///   Hive.registerAdapter(SaShellNoItemAdapter());  // typeId 11
class SaShellTypeShellNoService {
  static const _shellTypesBox = 'sa_shell_types_box';
  static const _shellNosBox   = 'sa_shell_nos_box';

  Future<void> init() async {
    await Hive.openBox<SaShellType>(_shellTypesBox);
    await Hive.openBox<SaShellNoItem>(_shellNosBox);
  }

  Box<SaShellType>   get _typesBox => Hive.box<SaShellType>(_shellTypesBox);
  Box<SaShellNoItem> get _nosBox   => Hive.box<SaShellNoItem>(_shellNosBox);

  Future<void> saveAll(List<ShellTypeWithNosData> items) async {
    await _typesBox.clear();
    await _nosBox.clear();

    for (final item in items) {
      await _typesBox.put(
        item.frameTypeId,
        SaShellType(id: item.frameTypeId, name: item.frameTypeName),
      );
      for (final sn in item.shellNos) {
        await _nosBox.put(
          sn.id,
          SaShellNoItem(
            id:          sn.id,
            formNo:      sn.formNo,
            stage:       sn.stage,
            shellTypeId: item.frameTypeId,
            status:      sn.status,
          ),
        );
      }
    }
  }

  Future<void> clearAll() async {
    await _typesBox.clear();
    await _nosBox.clear();
  }

  List<SaShellType> getShellTypes() => _typesBox.values.toList();

  /// Returns shell numbers belonging to the given [shellTypeId] (frame_type_id).
  List<SaShellNoItem> getShellNosByShellTypeId(String shellTypeId) =>
      _nosBox.values.where((e) => e.shellTypeId == shellTypeId).toList();
}
