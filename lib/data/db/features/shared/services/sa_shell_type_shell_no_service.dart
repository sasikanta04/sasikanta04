import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../api/shell/shell_no_by_shell_type_response.dart';
import '../models/sa_shell_no_item.dart';
import '../models/sa_shell_type.dart';

/// Shared master for Shell Type and Shell No dropdown data.
///
/// Fetched from /shellno-by-shelltype and persisted in a dedicated Hive box.
/// Kept separate from the dashboard controller's shared master calls.
/// Provides filtered getters for the parent-child dropdown relationship.
class SaShellTypeShellNoService {
  static const _boxName = 'sa_shell_type_shell_no_box';
  static const _dataKey = 'shell_types_with_nos';

  List<SaShellType>   _shellTypes = const [];
  List<SaShellNoItem> _shellNos   = const [];

  Future<void> init() async {
    await Hive.openBox<String>(_boxName);
    _loadFromBox();
  }

  void _loadFromBox() {
    final box = Hive.box<String>(_boxName);
    final raw = box.get(_dataKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = (jsonDecode(raw) as List? ?? [])
          .map((e) => ShellTypeData.fromJson(e as Map<String, dynamic>))
          .toList();
      _rebuild(list);
    } catch (_) {}
  }

  void _rebuild(List<ShellTypeData> items) {
    final types = <SaShellType>[];
    final nos   = <SaShellNoItem>[];

    for (final item in items) {
      types.add(SaShellType(id: item.id, title: item.title, code: item.code));
      for (final sn in item.shellNos) {
        nos.add(SaShellNoItem(
          id:          sn.id,
          shellNo:     sn.shellNo,
          shellTypeId: item.id,
          date:        sn.date,
        ));
      }
    }

    _shellTypes = List.unmodifiable(types);
    _shellNos   = List.unmodifiable(nos);
  }

  Future<void> saveAll(List<ShellTypeData> items) async {
    final box  = Hive.box<String>(_boxName);
    final json = jsonEncode(items.map((e) => e.toJson()).toList());
    await box.put(_dataKey, json);
    _rebuild(items);
  }

  Future<void> clearAll() async {
    final box = Hive.box<String>(_boxName);
    await box.delete(_dataKey);
    _shellTypes = const [];
    _shellNos   = const [];
  }

  List<SaShellType> getShellTypes() => _shellTypes;

  /// Returns shell numbers belonging to the given [shellTypeId].
  List<SaShellNoItem> getShellNosByShellTypeId(String shellTypeId) =>
      _shellNos.where((e) => e.shellTypeId == shellTypeId).toList();
}
