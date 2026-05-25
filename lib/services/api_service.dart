import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inspection_params.dart';
import '../models/shell_assembly_model.dart';
import '../models/qci_model.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';

class ApiService {
  // Replace with your actual base URL
  static const String _baseUrl = 'https://your-api-domain.com/api';

  /// Fetches all final inspection parameters.
  /// - Online: calls the API, caches result locally
  /// - Offline: returns cached result from local storage
  static Future<InspectionParams?> getFinalInspectionAllParams({
    required String inspectionId,
  }) async {
    final online = await ConnectivityService.isOnline();

    if (online) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/get-final-inspection-all-params')
              .replace(queryParameters: {'inspectionId': inspectionId}),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final params =
              InspectionParams.fromJson(jsonDecode(response.body));
          // Cache the latest params locally for offline use
          await LocalStorageService.saveInspectionParams(params);
          return params;
        }
      } catch (_) {
        // Network error — fall through to local cache
      }
    }

    // Offline or API failed — load from cache
    return LocalStorageService.loadInspectionParams();
  }

  /// Submit Shell Assembly form — saves locally always; syncs if online
  static Future<bool> submitShellAssembly(ShellAssemblyModel model) async {
    final online = await ConnectivityService.isOnline();

    if (online) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/submit-shell-assembly'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(model.toJson()),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200 || response.statusCode == 201) {
          model.isSynced = true;
          await LocalStorageService.saveShellAssembly(model);
          await LocalStorageService.removePendingSync(model.inspectionId);
          return true;
        }
      } catch (_) {
        // Fall through to local save
      }
    }

    // Save locally for later sync
    model.isSynced = false;
    await LocalStorageService.saveShellAssembly(model);
    return false;
  }

  /// Submit QCI form — saves locally always; syncs if online
  static Future<bool> submitQci(QciModel model) async {
    final online = await ConnectivityService.isOnline();

    if (online) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/submit-qci'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(model.toJson()),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200 || response.statusCode == 201) {
          model.isSynced = true;
          await LocalStorageService.saveQci(model);
          await LocalStorageService.removePendingSync(model.inspectionId);
          return true;
        }
      } catch (_) {
        // Fall through to local save
      }
    }

    model.isSynced = false;
    await LocalStorageService.saveQci(model);
    return false;
  }

  /// Sync all pending offline records when internet is restored
  static Future<void> syncPendingRecords() async {
    final online = await ConnectivityService.isOnline();
    if (!online) return;

    final pendingIds = await LocalStorageService.getPendingSyncIds();
    for (final id in pendingIds) {
      final shell = await LocalStorageService.loadShellAssembly(id);
      if (shell != null && !shell.isSynced) {
        await submitShellAssembly(shell);
      }

      final qci = await LocalStorageService.loadQci(id);
      if (qci != null && !qci.isSynced) {
        await submitQci(qci);
      }
    }
  }
}
