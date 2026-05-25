import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/api/shell/sa_final_saved_list_response.dart';
import '../../data/api/shell/shell_no_response.dart';
import '../../data/db/features/shared/services/all_frame_types_service.dart';
import '../../data/db/features/shared/services/all_makes_service.dart';
import '../../data/db/features/shared/services/all_shifts_service.dart';
import '../../data/db/features/shell_assembly/models/sa_all_metal_types.dart';
import '../../data/db/features/shell_assembly/models/sat_shell_no.dart';
import '../../data/db/features/shell_assembly/services/sa_all_metal_types_service.dart';
import '../../data/db/features/shell_assembly/services/sa_qci_form_param_service.dart';
import '../../data/db/features/shell_assembly/services/sa_qci_form_payload_service.dart';
import '../../data/db/features/shell_assembly/services/sat_shell_no_service.dart';
import '../../data/models/json/sa_qci_form_ui_model.dart';
import '../../data/models/select_options.dart';
import '../../data/provider/get_api_provider.dart';
import '../../services/config_api.dart';
import '../../services/pick_image_service.dart';
import '../../utils/app_utility.dart';

class AssemblyQciController extends GetxController {
  static AssemblyQciController to = Get.find();

  final allFrameTypesService = Get.find<AllFrameTypesService>();
  final saAllMetalTypesService = Get.find<SaAllMetalTypesService>();
  final allMakesService = Get.find<AllMakesService>();
  final allShiftsService = Get.find<AllShiftsService>();
  final satShellNoService = Get.find<SatShellNoService>();
  final _qciFormParamService = Get.find<SaQciFormParamService>();

  final shellAssemblyQciFormKey = GlobalKey<FormState>();
  final qciInspectionDateCtrl = TextEditingController(text: 'SELECT DATE');
  final ritesSupervisorDesignationQciController = TextEditingController();
  final RxnBool isConfirming = RxnBool();
  final RxBool showRadioValidation = false.obs;
  final RxBool showConfirmingWarning = false.obs;

  // ── Both-forms loading state ─────────────────────────────────────────────
  /// True while getFinalInspectionAllParams is fetching / hydrating forms.
  final RxBool isLoadingForms = false.obs;

  /// True once BOTH Shell Assembly and QCI forms are ready.
  final RxBool shellAssemblyFormReady = false.obs;
  final RxBool qciFormReady = false.obs;

  bool get bothFormsReady => shellAssemblyFormReady.value && qciFormReady.value;

  SelectOptions? selectedShellType;
  SelectOptions? selectedFormType;
  SelectOptions? selectedShellAssemblyBy;
  SelectOptions? selectedShift;
  SelectOptions? selectedShellNo;

  final List<SelectOptions> shellTypeList = [];
  final List<SelectOptions> formTypeList = [];
  final List<SelectOptions> shellAssemblyByList = [];
  final List<SelectOptions> shiftList = [];
  final List<SelectOptions> shellNoList = [];
  final Map<String, TextEditingController> _observedControllers = {};
  final Map<String, TextEditingController> _visualRemarkControllers = {};
  final Map<String, TextEditingController> _moduleOtherObsControllers = {};
  final Map<String, String?> _selectedObservedOptions = {};
  final Map<String, File> _qciVisualFailureImages = {};
  final Map<String, bool> _qciDimObservedOutOfRange = {};

  SaQciFormUiModel? qciForm;

  // ── SA final (QCI) server saved-form list ────────────────────────────────
  final RxInt saFinalCurrentPage = 1.obs;
  final RxInt saFinalPerPage = 10.obs;
  final RxInt saFinalTotalItems = 0.obs;
  final RxInt saFinalTotalPagesCount = 1.obs;
  final RxBool saFinalApiLoading = false.obs;
  final RxBool saFinalApiLoaded = false.obs;
  List<SaFinalDataList> saFinalApiRows = <SaFinalDataList>[];
  final RxBool saFinalSavedFormsBusy = false.obs;

  bool get shouldShowConfirmationError =>
      showRadioValidation.value && isConfirming.value == null;

  bool get isQciInspectionDateValid {
    final t = qciInspectionDateCtrl.text.trim().toUpperCase();
    return t.isNotEmpty && t != 'SELECT DATE';
  }

  int get qciOutOfRangeCount =>
      _qciDimObservedOutOfRange.values.where((e) => e).length;

  @override
  void onInit() {
    super.onInit();
    shellNoList.add(SelectOptions(key: '0', value: 'Select...', code: ''));
    _setDefaults();
  }

  @override
  void onClose() {
    for (final c in _observedControllers.values) c.dispose();
    _observedControllers.clear();
    for (final c in _visualRemarkControllers.values) c.dispose();
    _visualRemarkControllers.clear();
    for (final c in _moduleOtherObsControllers.values) c.dispose();
    _moduleOtherObsControllers.clear();
    qciInspectionDateCtrl.dispose();
    ritesSupervisorDesignationQciController.dispose();
    _qciDimObservedOutOfRange.clear();
    super.onClose();
  }

  void _setDefaults() {
    selectedShellType = null;
    selectedFormType = null;
    selectedShellAssemblyBy = null;
    selectedShift = null;
    selectedShellNo = null;
    shellAssemblyFormReady.value = false;
    qciFormReady.value = false;
  }

  SelectOptions? _qciSelectionAfterListReload({
    required List<SelectOptions> list,
    required String? previousKey,
  }) {
    if (previousKey == null || previousKey.isEmpty || previousKey == '0') {
      return null;
    }
    return list.firstWhereOrNull((e) => e.key == previousKey);
  }

  // ── Display helpers ────────────────────────────────────────────────────────

  String _normalizeText(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

  String moduleTitle(String key) {
    return switch (key) {
      'uf' => 'UNDER FRAME',
      'sw' => 'SIDE WALL',
      'ew' => 'END WALL',
      'roof' => 'ROOF',
      'shell' => 'SHELL',
      _ => key.toUpperCase(),
    };
  }

  static const List<String> qciModuleOrder = ['uf', 'sw', 'ew', 'roof', 'shell'];

  String? get selectedModuleKey {
    final code = _normalizeText(selectedFormType?.code ?? '');
    final value = _normalizeText(selectedFormType?.value ?? '');
    final source = '$code $value';
    if (source.contains('under') || source.contains('uf')) return 'uf';
    if (source.contains('side') || source.contains('sw')) return 'sw';
    if (source.contains('end') || source.contains('ew')) return 'ew';
    if (source.contains('roof')) return 'roof';
    if (source.contains('shell')) return 'shell';
    return null;
  }

  List<SaQciObservationItem> get selectedModuleDimensionalObs {
    final module = selectedModuleKey;
    if (module == null) return const <SaQciObservationItem>[];
    return qciForm?.dimensionalByModule[module] ?? const <SaQciObservationItem>[];
  }

  List<SaQciObservationItem> get selectedModuleVisualObs {
    final module = selectedModuleKey;
    if (module == null) return const <SaQciObservationItem>[];
    return qciForm?.visualByModule[module] ?? const <SaQciObservationItem>[];
  }

  Map<String, List<SaQciObservationItem>> get allDimensionalObsByModule =>
      qciForm?.dimensionalByModule ?? const {};

  Map<String, List<SaQciObservationItem>> get allVisualObsByModule =>
      qciForm?.visualByModule ?? const {};

  // ── Field-ID helpers ───────────────────────────────────────────────────────

  String observedFieldId({
    required String sectionKey,
    required String itemId,
    required int fieldIndex,
  }) =>
      '${_normalizeText(sectionKey)}|$itemId|$fieldIndex';

  String visualRemarkFieldId({
    required String sectionKey,
    required String itemId,
  }) =>
      '${_normalizeText(sectionKey)}|remark|$itemId';

  String qciVisualFailureImageId({
    required String sectionKey,
    required String itemId,
  }) =>
      '${_normalizeText(sectionKey)}|fail_img|$itemId';

  File? qciVisualFailureImage(String imageFieldId) =>
      _qciVisualFailureImages[imageFieldId];

  bool shouldShowQciVisualSelectionError({
    required String sectionKey,
    required String fieldId,
  }) {
    if (!showRadioValidation.value) return false;
    if (!sectionKey.endsWith('_visual_obs')) return false;
    return observedSelectedOption(fieldId) == null;
  }

  bool shouldShowQciVisualImageError({
    required String sectionKey,
    required SaQciObservationItem item,
  }) =>
      false;

  List<String> _activeQciModuleKeysForValidation() {
    final hasSelectedFormType =
        selectedFormType != null && selectedFormType?.key != '0';
    final selected = selectedModuleKey;
    if (hasSelectedFormType && selected != null) return <String>[selected];
    return List<String>.from(qciModuleOrder);
  }

  int _missingQciVisualSelectionCount() {
    var missing = 0;
    for (final module in _activeQciModuleKeysForValidation()) {
      final items = allVisualObsByModule[module] ?? const <SaQciObservationItem>[];
      final sectionKey = '${module}_visual_obs';
      for (final item in items) {
        for (var fi = 0; fi < item.fields.length; fi++) {
          final field = item.fields[fi];
          if (field.options.isEmpty) continue;
          final fieldId = observedFieldId(
            sectionKey: sectionKey,
            itemId: item.id,
            fieldIndex: fi,
          );
          if (observedSelectedOption(fieldId) == null) missing++;
        }
      }
    }
    return missing;
  }

  Future<void> captureQciVisualFailureImage({required String imageFieldId}) async {
    final shell = selectedShellNo;
    if (shell == null || shell.key == '0') {
      AppUtility.showToast(message: 'Please select Shell No.');
      return;
    }
    final frameNumber = shell.value.trim().isEmpty
        ? (shell.code?.trim() ?? '')
        : shell.value.trim();
    if (frameNumber.isEmpty) {
      AppUtility.showToast(message: 'Please select Shell No.');
      return;
    }
    final File? image =
        await PickImageService.captureAndSaveImage(frameNumber: frameNumber);
    if (image == null) return;
    _qciVisualFailureImages[imageFieldId] = image;
    update();
  }

  TextEditingController visualRemarkController({
    required String fieldId,
    String initialValue = '',
  }) =>
      _visualRemarkControllers.putIfAbsent(
          fieldId, () => TextEditingController(text: initialValue));

  TextEditingController observedController({
    required String fieldId,
    String initialValue = '',
  }) =>
      _observedControllers.putIfAbsent(
          fieldId, () => TextEditingController(text: initialValue));

  String moduleOtherObservationFieldId(String moduleKey) =>
      'qci|other_obs|${_normalizeText(moduleKey)}';

  TextEditingController moduleOtherObservationController({
    required String moduleKey,
    String initialValue = '',
  }) {
    final key = moduleOtherObservationFieldId(moduleKey);
    return _moduleOtherObsControllers.putIfAbsent(
        key, () => TextEditingController(text: initialValue));
  }

  bool qciObservedDimOutOfRange(String fieldId) =>
      _qciDimObservedOutOfRange[fieldId] ?? false;

  void updateQciDimensionalObservedRange({
    required String fieldId,
    double? minRange,
    double? maxRange,
    required String text,
  }) {
    var out = false;
    if (minRange != null && maxRange != null) {
      final t = text.trim();
      if (t.isNotEmpty) {
        final v = double.tryParse(t);
        if (v != null) out = v < minRange || v > maxRange;
      }
    }
    final was = _qciDimObservedOutOfRange[fieldId] ?? false;
    if (out) {
      _qciDimObservedOutOfRange[fieldId] = true;
    } else {
      _qciDimObservedOutOfRange.remove(fieldId);
    }
    if (was != out) update();
  }

  String? observedSelectedOption(String fieldId) =>
      _selectedObservedOptions[fieldId];

  void updateObservedOption({required String fieldId, required String? value}) {
    _selectedObservedOptions[fieldId] = value;
    update();
  }

  // ── Dropdown loaders ───────────────────────────────────────────────────────

  Future<void> setQciShellTypesFromDb() async {
    const selectedTrainType = 'lhb';
    final frameTypes = allFrameTypesService.getTypesByTrainType(selectedTrainType);
    shellTypeList
      ..clear()
      ..add(SelectOptions(key: '0', value: 'Select', code: ''));
    for (final item in frameTypes) {
      shellTypeList.add(SelectOptions(key: item.id, value: item.title, code: item.code));
    }
    final previousKey = selectedShellType?.key;
    selectedShellType = _qciSelectionAfterListReload(
      list: shellTypeList,
      previousKey: previousKey,
    );
    update();
  }

  Future<void> setQciFormTypesFromDb() async {
    final metalTypes = saAllMetalTypesService.getMetalTypes();
    formTypeList
      ..clear()
      ..add(SelectOptions(key: '0', value: 'Select', code: ''));
    for (final item in metalTypes) {
      final name = item.name.trim();
      if (name.isEmpty) continue;
      formTypeList.add(SelectOptions(key: item.id, value: name, code: item.code));
    }
    final previousKey = selectedFormType?.key;
    selectedFormType = _qciSelectionAfterListReload(
      list: formTypeList,
      previousKey: previousKey,
    );
    update();
  }

  Future<void> setQciAssemblyByFromDb() async {
    const selectedMetalType = 'shell-assembly';
    final makes = allMakesService.getMakesByMetalType(selectedMetalType);
    shellAssemblyByList
      ..clear()
      ..add(SelectOptions(key: '0', value: 'Select...', code: ''));
    for (final item in makes) {
      shellAssemblyByList.add(
          SelectOptions(key: item.id, value: item.title, code: item.code));
    }
    final previousKey = selectedShellAssemblyBy?.key;
    selectedShellAssemblyBy = _qciSelectionAfterListReload(
      list: shellAssemblyByList,
      previousKey: previousKey,
    );
    update();
  }

  Future<void> setQciShiftFromDb() async {
    final shifts = allShiftsService.getShifts();
    shiftList
      ..clear()
      ..add(SelectOptions(key: '0', value: 'Select', code: ''));
    for (final item in shifts) {
      shiftList.add(SelectOptions(key: item.id, value: item.name, code: item.code));
    }
    final previousKey = selectedShift?.key;
    selectedShift = _qciSelectionAfterListReload(
      list: shiftList,
      previousKey: previousKey,
    );
    update();
  }

  Future<void> getQciMetalTypes({
    required FutureOr<void> Function(bool completed) onComplete,
  }) async {
    await GetApiProvider().onGetProvider(
      onSuccess: (result) async {
        if (!result.status) {
          await onComplete(false);
          return;
        }
        try {
          final rows = <SaAllMetalTypes>[];
          for (final item in result.data) {
            if (item is! Map) continue;
            rows.add(SaAllMetalTypes.fromJson(Map<String, dynamic>.from(item)));
          }
          await saAllMetalTypesService.clearAll();
          await saAllMetalTypesService.saveMetalTypes(rows);
          await onComplete(rows.isNotEmpty);
        } catch (_) {
          await onComplete(false);
        }
      },
      onError: (_) async => await onComplete(false),
      url: ConfigApi.getMetalTypes,
    );
  }

  // ── Shell-type selection → opens BOTH forms ───────────────────────────────

  /// Called when user picks a shell type from the dropdown.
  /// Opens Shell Assembly form AND QCI form regardless of connectivity.
  void updateQciShellType(SelectOptions value) {
    selectedShellType = value.key == '0' ? null : value;
    shellAssemblyFormReady.value = false;
    qciFormReady.value = false;

    if (selectedShellType != null) {
      _loadAllFormsForFrameType(selectedShellType!.key);
    } else {
      qciForm = null;
      update();
    }
  }

  /// Loads BOTH Shell Assembly and QCI form params for [frameTypeId].
  ///
  /// Online  → calls `getFinalInspectionAllParams` API, saves to Hive, then
  ///            hydrates both form UIs.
  /// Offline → loads both from Hive cache; falls back to bundled asset for QCI.
  Future<void> _loadAllFormsForFrameType(String frameTypeId) async {
    isLoadingForms.value = true;
    update();

    final isOnline = await AppUtility.checkNetworkConn();

    if (isOnline && !_qciFormParamService.hasCached(frameTypeId: frameTypeId)) {
      // Fetch fresh params from API (saves to Hive inside the method)
      await getFinalInspectionAllParams(
        frameTypeId: frameTypeId,
        onComplete: (_) async {},
      );
    }

    // After fetch (or if already cached / offline), hydrate both forms from Hive
    await _hydrateShellAssemblyForm(frameTypeId);
    await _hydrateQciForm(frameTypeId);

    isLoadingForms.value = false;
    update();
  }

  /// Marks the Shell Assembly form as ready.
  /// Extend this method to populate SA-specific fields from the Hive cache.
  Future<void> _hydrateShellAssemblyForm(String frameTypeId) async {
    // Shell Assembly form fields are driven by the dropdowns already loaded
    // from local DB (metal types, shifts, makes). Mark ready unconditionally
    // so the form card renders immediately — online or offline.
    shellAssemblyFormReady.value = true;
    update();
  }

  /// Hydrates the QCI form from Hive cache → bundled asset fallback.
  Future<void> _hydrateQciForm(String frameTypeId) async {
    await loadQciFormFromHive(frameTypeId: frameTypeId);
    qciFormReady.value = true;
    update();
  }

  // ── API: get-final-inspection-all-params ──────────────────────────────────

  /// Calls `GET /get-final-inspection-all-params?frame_type_id=…`.
  ///
  /// • Online  → fetches from server, persists raw JSON to Hive.
  /// • Offline → [onComplete] is called with false; callers fall back to cache.
  Future<void> getFinalInspectionAllParams({
    required String frameTypeId,
    required FutureOr<void> Function(bool completed) onComplete,
  }) async {
    await GetApiProvider().onGetProviderWithParam(
      url: ConfigApi.getFinalInspectionAllParams,
      param: {'frame_type_id': frameTypeId},
      onSuccess: (result) async {
        try {
          final rawJson = jsonEncode(result.toJson());
          await _qciFormParamService.saveRawJson(rawJson, frameTypeId: frameTypeId);
          if (kDebugMode) {
            debugPrint(
                '[SA QCI] getFinalInspectionAllParams saved for $frameTypeId (${rawJson.length} bytes)');
          }
          await onComplete(true);
        } catch (e) {
          if (kDebugMode) debugPrint('[SA QCI] getFinalInspectionAllParams parse error: $e');
          await onComplete(false);
        }
      },
      onError: (_) async {
        if (kDebugMode) {
          debugPrint('[SA QCI] getFinalInspectionAllParams offline — using cached/asset');
        }
        await onComplete(false);
      },
    );
  }

  // ── QCI form hydration from Hive / bundled asset ──────────────────────────

  /// Priority: (1) Hive cache for [frameTypeId]  (2) bundled asset JSON.
  Future<void> loadQciFormFromHive({required String frameTypeId}) async {
    final cached = _qciFormParamService.getRawJson(frameTypeId: frameTypeId);
    if (cached != null && cached.isNotEmpty) {
      try {
        final decoded = jsonDecode(cached);
        if (decoded is Map<String, dynamic>) {
          qciForm = SaQciFormUiModel.fromJson(decoded);
          update();
          return;
        }
      } catch (_) {}
    }

    // Hive empty or corrupt → fall back to bundled asset
    try {
      final raw = await rootBundle.loadString('assets/json/sa_qci_form.json');
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      qciForm = SaQciFormUiModel.fromJson(decoded);
      update();
    } catch (_) {
      qciForm = null;
      update();
    }
  }

  // ── Form-type (module) selection ──────────────────────────────────────────

  void updateQciFormType(SelectOptions value) {
    selectedFormType = value.key == '0' ? null : value;
    _selectedObservedOptions.clear();
    for (final c in _observedControllers.values) c.clear();
    for (final c in _visualRemarkControllers.values) c.clear();
    for (final c in _moduleOtherObsControllers.values) c.clear();
    _qciVisualFailureImages.clear();
    _qciDimObservedOutOfRange.clear();
    showRadioValidation.value = false;
    showConfirmingWarning.value = false;
    isConfirming.value = null;
    ritesSupervisorDesignationQciController.clear();
    update();
  }

  void setConfirming(bool? value) {
    if (value == null) return;
    isConfirming.value = value;
    showConfirmingWarning.value = false;
    update();
  }

  void showWarning(bool? value) {
    if (value == null) return;
    if (value == true && qciOutOfRangeCount > 0) {
      showConfirmingWarning.value = true;
      update();
      return;
    }
    setConfirming(value);
  }

  void updateQciAssemblyBy(SelectOptions value) {
    selectedShellAssemblyBy = value.key == '0' ? null : value;
    update();
  }

  void updateQciShift(SelectOptions value) {
    selectedShift = value.key == '0' ? null : value;
    update();
  }

  void updateQciShellNo(SelectOptions value) {
    selectedShellNo = value.key == '0' ? null : value;
    update();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  void submitQciInspection() {
    showRadioValidation.value = true;
    update();
    final isValid = shellAssemblyQciFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      AppUtility.showToast(message: 'Please fill all required fields in the form.');
      return;
    }
    if (!isQciInspectionDateValid) {
      AppUtility.showToast(message: 'Please select inspection date.');
      return;
    }
    final missingVisualSelection = _missingQciVisualSelectionCount();
    if (missingVisualSelection > 0) {
      AppUtility.showToast(
          message: 'Please complete all fields in the Visual Observations section.');
      return;
    }
    if (isConfirming.value == null) {
      AppUtility.showToast(message: 'Please select confirming status.');
      return;
    }
    if (isConfirming.value == true && qciOutOfRangeCount > 0) {
      showConfirmingWarning.value = true;
      AppUtility.showToast(
          message:
              '$qciOutOfRangeCount observed value(s) are out of range. Please correct them or select Non-Confirming.');
      update();
      return;
    }

    AppUtility.showToast(message: 'QCI inspection saved.');
    _saveQciInspection();
  }

  // ── Internal save ──────────────────────────────────────────────────────────

  Future<void> _saveQciInspection() async {
    final formDetails = {
      'shell_no': selectedShellNo?.value ?? '',
      'shell_type_code': selectedShellType?.code ?? '',
      'shell_type_label': selectedShellType?.value ?? '',
      'form_type': selectedFormType?.value ?? '',
      'shell_type': selectedShellType?.value ?? '',
      'assembly_by': selectedShellAssemblyBy?.value ?? '',
      'shift': selectedShift?.value ?? '',
      'inspection_date': qciInspectionDateCtrl.text,
    };

    final dimObs = <String, String>{};
    for (final e in _observedControllers.entries) dimObs[e.key] = e.value.text.trim();

    final visObs = Map<String, String?>.from(_selectedObservedOptions);

    final visRemarks = <String, String>{};
    for (final e in _visualRemarkControllers.entries) visRemarks[e.key] = e.value.text.trim();

    final moduleOther = <String, String>{};
    for (final e in _moduleOtherObsControllers.entries)
      moduleOther[e.key] = e.value.text.trim();

    final formData = {
      'dimensional_obs': dimObs,
      'visual_obs': visObs,
      'visual_remarks': visRemarks,
      'module_other_obs': moduleOther,
      'is_confirming': isConfirming.value,
      'rites_supervisor_designation':
          ritesSupervisorDesignationQciController.text.trim(),
    };

    if (kDebugMode) {
      debugPrint('─── FORM DETAILS ─────────────────────────────────────');
      debugPrint('  shell_no          : ${formDetails['shell_no']}');
      debugPrint('  shell_type        : ${formDetails['shell_type']}');
      debugPrint('  shell_type_code   : ${formDetails['shell_type_code']}');
      debugPrint('  form_type         : ${formDetails['form_type']}');
      debugPrint('  assembly_by       : ${formDetails['assembly_by']}');
      debugPrint('  shift             : ${formDetails['shift']}');
      debugPrint('  inspection_date   : ${formDetails['inspection_date']}');
      debugPrint('─── FORM DATA ────────────────────────────────────────');
      debugPrint('  is_confirming          : ${formData['is_confirming']}');
      debugPrint(
          '  rites_supervisor_desig : ${formData['rites_supervisor_designation']}');
      debugPrint('  dimensional_obs (${dimObs.length} entries):');
      dimObs.forEach((k, v) => debugPrint('    $k = "$v"'));
      debugPrint('  visual_obs (${visObs.length} entries):');
      visObs.forEach((k, v) => debugPrint('    $k = "$v"'));
      final nonEmptyRemarks =
          Map.fromEntries(visRemarks.entries.where((e) => e.value.isNotEmpty));
      debugPrint('  visual_remarks (${nonEmptyRemarks.length} non-empty):');
      nonEmptyRemarks.forEach((k, v) => debugPrint('    $k = "$v"'));
      final nonEmptyOther =
          Map.fromEntries(moduleOther.entries.where((e) => e.value.isNotEmpty));
      debugPrint('  module_other_obs (${nonEmptyOther.length} non-empty):');
      nonEmptyOther.forEach((k, v) => debugPrint('    $k = "$v"'));
      debugPrint('══════════════════════════════════════════════════════\n');
    }

    // TODO: persist / sync formDetails + formData via API or local DB

    _resetQciForm();
  }

  /// Resets all QCI form state back to defaults.
  void _resetQciForm() {
    _setDefaults();
    qciInspectionDateCtrl.text = 'SELECT DATE';
    ritesSupervisorDesignationQciController.clear();
    for (final c in _observedControllers.values) c.clear();
    for (final c in _visualRemarkControllers.values) c.clear();
    for (final c in _moduleOtherObsControllers.values) c.clear();
    _selectedObservedOptions.clear();
    _qciVisualFailureImages.clear();
    _qciDimObservedOutOfRange.clear();
    showRadioValidation.value = false;
    showConfirmingWarning.value = false;
    isConfirming.value = null;
    qciForm = null;
    update();
  }

  // ── Shell numbers ──────────────────────────────────────────────────────────

  Future<void> getSatShellNumbers({
    required FutureOr<void> Function(bool completed) onComplete,
  }) async {
    await GetApiProvider().onGetProvider(
      onSuccess: (result) async {
        if (!result.status) {
          await onComplete(false);
          return;
        }
        try {
          final parsed = ShellNoResponse.fromJson(result.toJson());
          final list = parsed.data ?? [];
          final rows = <SatShellNo>[];
          for (final item in list) {
            rows.add(SatShellNo(
              id: (item.id ?? '').toString(),
              shellNo: (item.shellNo ?? '').toString(),
              date: item.date != null
                  ? '${item.date!.year.toString().padLeft(4, '0')}-'
                      '${item.date!.month.toString().padLeft(2, '0')}-'
                      '${item.date!.day.toString().padLeft(2, '0')}'
                  : '',
            ));
          }
          await satShellNoService.saveAllShellNo(rows);
          await onComplete(rows.isNotEmpty);
        } catch (_) {
          await onComplete(false);
        }
      },
      onError: (_) async => await onComplete(false),
      url: ConfigApi.getShellNumbers,
    );
  }

  Future<void> setQciShellNoFromDb() async {
    final shellNos = satShellNoService.getAllShellNo();
    shellNoList
      ..clear()
      ..add(SelectOptions(key: '0', value: 'Select...', code: ''));
    for (final item in shellNos) {
      shellNoList.add(
          SelectOptions(key: item.id, value: item.shellNo, code: item.shellNo));
    }
    final previousKey = selectedShellNo?.key;
    selectedShellNo =
        shellNoList.firstWhereOrNull((e) => e.key == previousKey && e.key != '0');
    update();
  }

  // ── SA final saved-forms list (server) ────────────────────────────────────

  List<dynamic> getSaFinalOfflineSavedRows() => const [];
  int get saFinalUnsyncedPayloadCount => 0;
  bool get hasSaFinalOfflinePendingSync => false;

  bool get shouldShowSaFinalApiList =>
      !hasSaFinalOfflinePendingSync && saFinalUnsyncedPayloadCount == 0;

  bool isSaFinalSavedFormsBusy() => saFinalSavedFormsBusy.value;

  int get saFinalTotalPages {
    if (saFinalTotalPagesCount.value > 0) return saFinalTotalPagesCount.value;
    final per = saFinalPerPage.value;
    if (per <= 0) return 1;
    final pages = (saFinalTotalItems.value / per).ceil();
    return pages <= 0 ? 1 : pages;
  }

  List<int> get saFinalVisiblePageNumbers =>
      _qciBuildVisiblePageNumbers(saFinalTotalPages);

  List<int> _qciBuildVisiblePageNumbers(int totalPages) {
    if (totalPages <= 0) return [1];
    if (totalPages > 5) return [1, 2, 3, -1, totalPages];
    return List.generate(totalPages, (index) => index + 1);
  }

  int _qciParseApiPaginationInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  void resetSaFinalApiState() {
    saFinalApiRows = <SaFinalDataList>[];
    saFinalCurrentPage.value = 1;
    saFinalPerPage.value = 10;
    saFinalTotalItems.value = 0;
    saFinalTotalPagesCount.value = 1;
    saFinalApiLoaded.value = false;
    update();
  }

  Future<bool> loadSaFinalApiList({int? page}) async {
    if (saFinalApiLoading.value) return false;
    final previousPage = saFinalCurrentPage.value;
    final requestedPage = page ?? previousPage;
    saFinalApiLoading.value = true;
    update();
    var completed = false;
    try {
      await GetApiProvider().onGetProviderWithParamMap(
        url: ConfigApi.getSaFinalSavedFormList,
        param: {'page': requestedPage, 'per_page': saFinalPerPage.value},
        onSuccess: (payload) async {
          if (payload is! Map) {
            saFinalCurrentPage.value = previousPage;
            completed = false;
            return;
          }
          try {
            final response = SaFinalAllListResponse.fromJson(
                Map<String, dynamic>.from(payload));
            saFinalApiRows = List<SaFinalDataList>.from(
                response.data ?? const <SaFinalDataList>[]);
            saFinalCurrentPage.value = _qciParseApiPaginationInt(
                response.currentPage,
                fallback: requestedPage);
            saFinalPerPage.value = _qciParseApiPaginationInt(response.perPage,
                fallback: saFinalPerPage.value);
            saFinalTotalItems.value = response.total ?? saFinalApiRows.length;
            saFinalTotalPagesCount.value = response.totalPages ??
                ((saFinalTotalItems.value / saFinalPerPage.value).ceil());
            if (saFinalTotalPagesCount.value <= 0) saFinalTotalPagesCount.value = 1;
            if (saFinalCurrentPage.value > saFinalTotalPagesCount.value) {
              saFinalCurrentPage.value = saFinalTotalPagesCount.value;
            }
            saFinalApiLoaded.value = true;
            completed = true;
          } catch (e) {
            saFinalCurrentPage.value = previousPage;
            if (kDebugMode) debugPrint('SA final list API error: $e');
            completed = false;
          }
        },
        onError: (e) async {
          saFinalCurrentPage.value = previousPage;
          if (kDebugMode) debugPrint('SA final list API error: $e');
          if (e is DioException) {
            final message = e.error?.toString() ?? e.message ?? '';
            if (message.contains('Connection closed before full header')) {
              AppUtility.showToast(
                  message: 'Connection issue while loading page. Please retry.');
            }
          }
          completed = false;
        },
      );
    } catch (e) {
      saFinalCurrentPage.value = previousPage;
      if (kDebugMode) debugPrint('SA final list API error: $e');
      completed = false;
    }
    saFinalApiLoading.value = false;
    update();
    return completed;
  }

  Future<void> goToSaFinalPage(int page) async {
    if (page == saFinalCurrentPage.value) return;
    if (page < 1 || page > saFinalTotalPages) return;
    await loadSaFinalApiList(page: page);
  }

  Future<void> goToSaFinalNextPage() async {
    if (saFinalCurrentPage.value >= saFinalTotalPages) return;
    await loadSaFinalApiList(page: saFinalCurrentPage.value + 1);
  }

  Future<void> goToSaFinalPreviousPage() async {
    if (saFinalCurrentPage.value <= 1) return;
    await loadSaFinalApiList(page: saFinalCurrentPage.value - 1);
  }

  Future<void> _refreshSaFinalSavedFormApiIfNoPending() async {
    if (saFinalUnsyncedPayloadCount > 0) return;
    if (!await AppUtility.checkNetworkConn()) return;
    await loadSaFinalApiList(page: saFinalCurrentPage.value);
  }

  // ── View helpers ───────────────────────────────────────────────────────────

  String qciViewDisplay(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? '—' : text;
  }

  String _qciTitleFromOptions(String keyOrName, List<SelectOptions> options) {
    final t = keyOrName.trim();
    if (t.isEmpty) return '—';
    for (final o in options) {
      final key = o.key.trim();
      final value = o.value.trim();
      final code = (o.code ?? '').trim();
      if (key == t || value == t || code == t) {
        if (value.isNotEmpty && value.toLowerCase() != 'select') return value;
        if (code.isNotEmpty) return code;
        if (key.isNotEmpty && key != '0') return key;
      }
    }
    return t;
  }

  String qciFormTypeTitleByKey(String keyOrName) =>
      _qciTitleFromOptions(keyOrName, formTypeList);
  String qciShellTypeTitleByKey(String keyOrName) =>
      _qciTitleFromOptions(keyOrName, shellTypeList);
  String qciShellNoTitleByKey(String keyOrName) =>
      _qciTitleFromOptions(keyOrName, shellNoList);
  String qciShiftTitleByKey(String keyOrName) =>
      _qciTitleFromOptions(keyOrName, shiftList);
  String qciAssemblyByTitleByKey(String keyOrName) =>
      _qciTitleFromOptions(keyOrName, shellAssemblyByList);

  String qciViewFormattedDate(SaFinalDataList data) {
    final formatted = (data.formatDate ?? '').trim();
    if (formatted.isNotEmpty) return formatted;
    return qciViewDisplay(data.date);
  }

  Future<void> refreshSaFinalSavedForms() async {
    if (shouldShowSaFinalApiList) {
      await loadSaFinalApiList(page: saFinalCurrentPage.value);
    }
    update();
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  Future<void> syncAllSaFinalSavedFormsWithLoader() async {
    if (isSaFinalSavedFormsBusy()) return;
    saFinalSavedFormsBusy.value = true;
    update();
    try {
      await _refreshSaFinalSavedFormApiIfNoPending();
    } finally {
      saFinalSavedFormsBusy.value = false;
      update();
    }
  }
}
