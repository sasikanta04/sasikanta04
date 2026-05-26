import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// Root response
// ─────────────────────────────────────────────────────────────────────────────

class SaQciAllFormsResponse {
  final bool?         success;
  final bool?         status;
  final String?       message;
  final List<SaQciFormDatum> data;

  const SaQciAllFormsResponse({
    this.success,
    this.status,
    this.message,
    this.data = const [],
  });

  factory SaQciAllFormsResponse.fromRawJson(String str) =>
      SaQciAllFormsResponse.fromJson(json.decode(str) as Map<String, dynamic>);

  factory SaQciAllFormsResponse.fromJson(Map<String, dynamic> j) =>
      SaQciAllFormsResponse(
        success: j['success'] as bool?,
        status:  j['status']  as bool?,
        message: j['message'] as String?,
        data: (j['data'] as List? ?? [])
            .map((e) => SaQciFormDatum.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'status':  status,
        'message': message,
        'data':    data.map((e) => e.toJson()).toList(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// One item in data[]  →  { frame_type_id, data: { ... } }
// ─────────────────────────────────────────────────────────────────────────────

class SaQciFormDatum {
  final String         frameTypeId;
  final SaQciFormData? data;

  const SaQciFormDatum({required this.frameTypeId, this.data});

  factory SaQciFormDatum.fromJson(Map<String, dynamic> j) => SaQciFormDatum(
        frameTypeId: (j['frame_type_id'] ?? '').toString(),
        data: j['data'] == null
            ? null
            : SaQciFormData.fromJson(j['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'frame_type_id': frameTypeId,
        'data':          data?.toJson(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Inner data object — all 5 modules (UF / SW / EW / Roof / Shell)
// ─────────────────────────────────────────────────────────────────────────────

class SaQciFormData {
  final String shortCode;

  final List<SaQciVisualObItem> ufVisualObs;
  final List<SaQciDimGroup>     ufDimesionalObs;

  final List<SaQciVisualObItem> swVisualObs;
  final List<SaQciDimGroup>     swDimesionalObs;

  final List<SaQciVisualObItem> ewVisualObs;
  final List<SaQciDimGroup>     ewDimesionalObs;

  final List<SaQciVisualObItem> roofVisualObs;
  final List<SaQciDimGroup>     roofDimesionalObs;

  final List<SaQciVisualObItem> shellVisualObs;
  final List<SaQciDimGroup>     shellDimesionalObs;

  const SaQciFormData({
    this.shortCode          = '',
    this.ufVisualObs        = const [],
    this.ufDimesionalObs    = const [],
    this.swVisualObs        = const [],
    this.swDimesionalObs    = const [],
    this.ewVisualObs        = const [],
    this.ewDimesionalObs    = const [],
    this.roofVisualObs      = const [],
    this.roofDimesionalObs  = const [],
    this.shellVisualObs     = const [],
    this.shellDimesionalObs = const [],
  });

  factory SaQciFormData.fromJson(Map<String, dynamic> j) => SaQciFormData(
        shortCode: (j['short_code'] ?? '').toString(),

        ufVisualObs:     _visualList(j['uf_visual_obs']),
        ufDimesionalObs: _dimList(j['uf_dimesional_obs']),

        swVisualObs:     _visualList(j['sw_visual_obs']),
        swDimesionalObs: _dimList(j['sw_dimesional_obs']),

        ewVisualObs:     _visualList(j['ew_visual_obs']),
        ewDimesionalObs: _dimList(j['ew_dimesional_obs']),

        roofVisualObs:     _visualList(j['roof_visual_obs']),
        roofDimesionalObs: _dimList(j['roof_dimesional_obs']),

        shellVisualObs:     _visualList(j['shell_visual_obs']),
        shellDimesionalObs: _dimList(j['shell_dimesional_obs']),
      );

  Map<String, dynamic> toJson() => {
        'short_code':           shortCode,
        'uf_visual_obs':        ufVisualObs.map((e) => e.toJson()).toList(),
        'uf_dimesional_obs':    ufDimesionalObs.map((e) => e.toJson()).toList(),
        'sw_visual_obs':        swVisualObs.map((e) => e.toJson()).toList(),
        'sw_dimesional_obs':    swDimesionalObs.map((e) => e.toJson()).toList(),
        'ew_visual_obs':        ewVisualObs.map((e) => e.toJson()).toList(),
        'ew_dimesional_obs':    ewDimesionalObs.map((e) => e.toJson()).toList(),
        'roof_visual_obs':      roofVisualObs.map((e) => e.toJson()).toList(),
        'roof_dimesional_obs':  roofDimesionalObs.map((e) => e.toJson()).toList(),
        'shell_visual_obs':     shellVisualObs.map((e) => e.toJson()).toList(),
        'shell_dimesional_obs': shellDimesionalObs.map((e) => e.toJson()).toList(),
      };

  static List<SaQciVisualObItem> _visualList(dynamic raw) =>
      (raw as List? ?? [])
          .map((e) => SaQciVisualObItem.fromJson(e as Map<String, dynamic>))
          .toList();

  static List<SaQciDimGroup> _dimList(dynamic raw) =>
      (raw as List? ?? [])
          .map((e) => SaQciDimGroup.fromJson(e as Map<String, dynamic>))
          .toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Visual observation item
// { description, specified_val, obs_val: [{key, val}] }
// ─────────────────────────────────────────────────────────────────────────────

class SaQciVisualObItem {
  final String           description;
  final dynamic          specifiedVal;
  final List<SaQciObsVal> obsVal;

  const SaQciVisualObItem({
    this.description  = '',
    this.specifiedVal,
    this.obsVal = const [],
  });

  factory SaQciVisualObItem.fromJson(Map<String, dynamic> j) => SaQciVisualObItem(
        description:  (j['description']   ?? '').toString(),
        specifiedVal: j['specified_val'],
        obsVal: (j['obs_val'] as List? ?? [])
            .map((e) => SaQciObsVal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'description':   description,
        'specified_val': specifiedVal,
        'obs_val':       obsVal.map((e) => e.toJson()).toList(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Dimensional observation group  →  { innerData: [...] }
// ─────────────────────────────────────────────────────────────────────────────

class SaQciDimGroup {
  final List<SaQciDimInnerItem> innerData;

  const SaQciDimGroup({this.innerData = const []});

  factory SaQciDimGroup.fromJson(Map<String, dynamic> j) => SaQciDimGroup(
        innerData: (j['innerData'] as List? ?? [])
            .map((e) => SaQciDimInnerItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'innerData': innerData.map((e) => e.toJson()).toList(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// One row inside innerData
// ─────────────────────────────────────────────────────────────────────────────

class SaQciDimInnerItem {
  final int?            no;
  final String          underFrameType;
  final String          metalTypeId;
  final String          stageId;
  final String          visualTypeId;
  final String          description;
  final String          id;
  final List<dynamic>   remarks;
  final List<SaQciDimParam> params;
  final String?         radio;

  const SaQciDimInnerItem({
    this.no,
    this.underFrameType = '',
    this.metalTypeId    = '',
    this.stageId        = '',
    this.visualTypeId   = '',
    this.description    = '',
    this.id             = '',
    this.remarks        = const [],
    this.params         = const [],
    this.radio,
  });

  factory SaQciDimInnerItem.fromJson(Map<String, dynamic> j) => SaQciDimInnerItem(
        no:             j['no'] as int?,
        underFrameType: (j['under_frame_type'] ?? '').toString(),
        metalTypeId:    (j['metal_type_id']    ?? '').toString(),
        stageId:        (j['stage_id']         ?? '').toString(),
        visualTypeId:   (j['visual_type_id']   ?? '').toString(),
        description:    (j['description']      ?? '').toString(),
        id:             (j['id']               ?? '').toString(),
        remarks:  List<dynamic>.from(j['remarks'] ?? []),
        params: (j['params'] as List? ?? [])
            .map((e) => SaQciDimParam.fromJson(e as Map<String, dynamic>))
            .toList(),
        radio: j['radio'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'no':               no,
        'under_frame_type': underFrameType,
        'metal_type_id':    metalTypeId,
        'stage_id':         stageId,
        'visual_type_id':   visualTypeId,
        'description':      description,
        'id':               id,
        'remarks':          remarks,
        'params':           params.map((e) => e.toJson()).toList(),
        'radio':            radio,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Param  →  { value, is_visual_type_obs, lateral_params: [...] }
// ─────────────────────────────────────────────────────────────────────────────

class SaQciDimParam {
  final String?               value;
  final int?                  isVisualTypeObs;
  final List<SaQciLateralParam> lateralParams;

  const SaQciDimParam({
    this.value,
    this.isVisualTypeObs,
    this.lateralParams = const [],
  });

  factory SaQciDimParam.fromJson(Map<String, dynamic> j) => SaQciDimParam(
        value:           j['value'] as String?,
        isVisualTypeObs: j['is_visual_type_obs'] as int?,
        lateralParams: (j['lateral_params'] as List? ?? [])
            .map((e) => SaQciLateralParam.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'value':              value,
        'is_visual_type_obs': isVisualTypeObs,
        'lateral_params':     lateralParams.map((e) => e.toJson()).toList(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Lateral param  →  { value, main_label, child_val: [...] }
// ─────────────────────────────────────────────────────────────────────────────

class SaQciLateralParam {
  final String?           value;
  final String?           mainLabel;
  final List<SaQciChildVal> childVal;

  const SaQciLateralParam({
    this.value,
    this.mainLabel,
    this.childVal = const [],
  });

  factory SaQciLateralParam.fromJson(Map<String, dynamic> j) => SaQciLateralParam(
        value:     j['value']      as String?,
        mainLabel: j['main_label'] as String?,
        childVal: (j['child_val'] as List? ?? [])
            .map((e) => SaQciChildVal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'value':      value,
        'main_label': mainLabel,
        'child_val':  childVal.map((e) => e.toJson()).toList(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Child value  →  { sub_child_label, sub_child_val, min_range, max_range,
//                   obs_Value, obs_val }
// ─────────────────────────────────────────────────────────────────────────────

class SaQciChildVal {
  final String?          subChildLabel;
  final String?          subChildVal;
  final double?          minRange;
  final double?          maxRange;
  final List<dynamic>    obsValue; // obs_Value (display)
  final List<SaQciObsVal> obsVal;  // obs_val  (selectable options)

  const SaQciChildVal({
    this.subChildLabel,
    this.subChildVal,
    this.minRange,
    this.maxRange,
    this.obsValue = const [],
    this.obsVal   = const [],
  });

  factory SaQciChildVal.fromJson(Map<String, dynamic> j) => SaQciChildVal(
        subChildLabel: j['sub_child_label'] as String?,
        subChildVal:   j['sub_child_val']   as String?,
        minRange:      _toDouble(j['min_range']),
        maxRange:      _toDouble(j['max_range']),
        obsValue: List<dynamic>.from(j['obs_Value'] ?? []),
        obsVal: (j['obs_val'] as List? ?? [])
            .map((e) => SaQciObsVal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'sub_child_label': subChildLabel,
        'sub_child_val':   subChildVal,
        'min_range':       minRange,
        'max_range':       maxRange,
        'obs_Value':       obsValue,
        'obs_val':         obsVal.map((e) => e.toJson()).toList(),
      };

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num)  return v.toDouble();
    return double.tryParse(v.toString());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// obs_val item  →  { key: "OK", val: "1" }
// ─────────────────────────────────────────────────────────────────────────────

class SaQciObsVal {
  final String  key; // display label  e.g. "OK", "Not OK"
  final dynamic val; // stored value   e.g. 1 or "1"

  const SaQciObsVal({required this.key, this.val});

  factory SaQciObsVal.fromJson(Map<String, dynamic> j) => SaQciObsVal(
        key: (j['key'] ?? '').toString(),
        val: j['val'],
      );

  Map<String, dynamic> toJson() => {'key': key, 'val': val};
}
