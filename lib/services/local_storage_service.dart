import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inspection_params.dart';
import '../models/shell_assembly_model.dart';
import '../models/qci_model.dart';

class LocalStorageService {
  static const _paramsKey = 'inspection_params';
  static const _shellKey = 'shell_assembly_data';
  static const _qciKey = 'qci_data';
  static const _pendingSyncKey = 'pending_sync_ids';

  // ---------- Inspection Params ----------

  static Future<void> saveInspectionParams(InspectionParams params) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paramsKey, jsonEncode(params.toJson()));
  }

  static Future<InspectionParams?> loadInspectionParams() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_paramsKey);
    if (raw == null) return null;
    return InspectionParams.fromJson(jsonDecode(raw));
  }

  // ---------- Shell Assembly ----------

  static Future<void> saveShellAssembly(ShellAssemblyModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final allRaw = prefs.getString(_shellKey);
    final Map<String, dynamic> all =
        allRaw != null ? jsonDecode(allRaw) : {};
    all[model.inspectionId] = model.toJson();
    await prefs.setString(_shellKey, jsonEncode(all));
    if (!model.isSynced) await _addPendingSync(model.inspectionId);
  }

  static Future<ShellAssemblyModel?> loadShellAssembly(
      String inspectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final allRaw = prefs.getString(_shellKey);
    if (allRaw == null) return null;
    final Map<String, dynamic> all = jsonDecode(allRaw);
    final data = all[inspectionId];
    if (data == null) return null;
    return ShellAssemblyModel.fromJson(data);
  }

  // ---------- QCI ----------

  static Future<void> saveQci(QciModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final allRaw = prefs.getString(_qciKey);
    final Map<String, dynamic> all =
        allRaw != null ? jsonDecode(allRaw) : {};
    all[model.inspectionId] = model.toJson();
    await prefs.setString(_qciKey, jsonEncode(all));
    if (!model.isSynced) await _addPendingSync(model.inspectionId);
  }

  static Future<QciModel?> loadQci(String inspectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final allRaw = prefs.getString(_qciKey);
    if (allRaw == null) return null;
    final Map<String, dynamic> all = jsonDecode(allRaw);
    final data = all[inspectionId];
    if (data == null) return null;
    return QciModel.fromJson(data);
  }

  // ---------- Pending Sync ----------

  static Future<void> _addPendingSync(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_pendingSyncKey) ?? [];
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList(_pendingSyncKey, ids);
    }
  }

  static Future<List<String>> getPendingSyncIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pendingSyncKey) ?? [];
  }

  static Future<void> removePendingSync(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_pendingSyncKey) ?? [];
    ids.remove(id);
    await prefs.setStringList(_pendingSyncKey, ids);
  }
}
