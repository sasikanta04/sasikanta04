import 'package:flutter/material.dart';
import '../models/inspection_params.dart';
import '../models/shell_assembly_model.dart';
import '../models/qci_model.dart';
import 'api_service.dart';
import 'connectivity_service.dart';

enum LoadState { idle, loading, loaded, error }

class InspectionProvider extends ChangeNotifier {
  LoadState loadState = LoadState.idle;
  bool isOnline = true;
  String? errorMessage;

  InspectionParams? params;
  ShellAssemblyModel? shellModel;
  QciModel? qciModel;

  bool shellSubmitting = false;
  bool qciSubmitting = false;
  bool shellSubmitted = false;
  bool qciSubmitted = false;

  InspectionProvider() {
    _listenConnectivity();
  }

  void _listenConnectivity() {
    ConnectivityService.onConnectivityChanged.listen((results) async {
      final nowOnline = await ConnectivityService.isOnline();
      if (!isOnline && nowOnline) {
        isOnline = true;
        notifyListeners();
        // Auto-sync pending records when internet returns
        await ApiService.syncPendingRecords();
      } else {
        isOnline = nowOnline;
        notifyListeners();
      }
    });
  }

  Future<void> loadParams(String inspectionId) async {
    loadState = LoadState.loading;
    errorMessage = null;
    notifyListeners();

    isOnline = await ConnectivityService.isOnline();
    params = await ApiService.getFinalInspectionAllParams(
        inspectionId: inspectionId);

    if (params != null) {
      shellModel = ShellAssemblyModel(inspectionId: params!.inspectionId);
      qciModel = QciModel(inspectionId: params!.inspectionId);
      loadState = LoadState.loaded;
    } else {
      errorMessage = isOnline
          ? 'Failed to load inspection parameters from server.'
          : 'No cached data available. Please connect to the internet first.';
      loadState = LoadState.error;
    }

    notifyListeners();
  }

  Future<bool> submitShellAssembly() async {
    if (shellModel == null) return false;
    shellSubmitting = true;
    notifyListeners();

    final success = await ApiService.submitShellAssembly(shellModel!);
    shellSubmitting = false;
    shellSubmitted = true;
    notifyListeners();
    return success;
  }

  Future<bool> submitQci() async {
    if (qciModel == null) return false;
    qciSubmitting = true;
    notifyListeners();

    final success = await ApiService.submitQci(qciModel!);
    qciSubmitting = false;
    qciSubmitted = true;
    notifyListeners();
    return success;
  }

  bool get bothFormsSubmitted => shellSubmitted && qciSubmitted;
}
