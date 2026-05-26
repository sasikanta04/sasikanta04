import 'dart:convert';

// ═══════════════════════════════════════════════════════════════════════════
//  ShellQciForm  —  API response model for getSaQciAllParams
//
//  Endpoint returns:
//  {
//    "success": true,
//    "status": true,
//    "message": "...",
//    "data": [               ← 23 items, one per frame_type_id
//      {
//        "frame_type_id": "69b398dfb092009faf05b198",
//        "data": {
//          "short_code": "3T- GARIBRATH",
//          "uf_visual_obs":        [...],
//          "uf_dimesional_obs":    [{ "innerData": [...] }],
//          "sw_visual_obs":        [...],
//          "sw_dimesional_obs":    [{ "innerData": [...] }],
//          "ew_visual_obs":        [...],
//          "ew_dimesional_obs":    [{ "innerData": [...] }],
//          "roof_visual_obs":      [...],
//          "roof_dimesional_obs":  [{ "innerData": [...] }],
//          "shell_visual_obs":     [...],
//          "shell_dimesional_obs": [{ "innerData": [...] }]
//        }
//      },
//      ...
//    ]
//  }
// ═══════════════════════════════════════════════════════════════════════════

// ── Root response ────────────────────────────────────────────────────────────

class ShellQciForm {
  final bool?   success;
  final bool?   status;
  final String? message;
  final List<ShellQciDatum> data;

  const ShellQciForm({
    this.success,
    this.status,
    this.message,
    this.data = const [],
  });

  factory ShellQciForm.fromRawJson(String str) =>
      ShellQciForm.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ShellQciForm.fromJson(Map<String, dynamic> j) => ShellQciForm(
        success: j['success'] as bool?,
        status:  j['status']  as bool?,
        message: j['message'] as String?,
        data: (j['data'] as List? ?? [])
            .map((e) => ShellQciDatum.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'status':  status,
        'message': message,
        'data':    data.map((e) => e.toJson()).toList(),
      };
}

// ── One item in data[]  { frame_type_id, data: { ... } } ─────────────────────

class ShellQciDatum {
  final String        frameTypeId;
  final ShellQciData? data;

  const ShellQciDatum({required this.frameTypeId, this.data});

  factory ShellQciDatum.fromJson(Map<String, dynamic> j) => ShellQciDatum(
        frameTypeId: (j['frame_type_id'] ?? '').toString(),
        data: j['data'] == null
            ? null
            : ShellQciData.fromJson(j['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'frame_type_id': frameTypeId,
        'data':          data?.toJson(),
      };
}

// ── Inner data — all 5 modules (UF / SW / EW / Roof / Shell) ─────────────────

class ShellQciData {
  final String shortCode;

  final List<ShellQciVisualOb> ufVisualObs;
  final List<ShellQciDimGroup> ufDimesionalObs;

  final List<ShellQciVisualOb> swVisualObs;
  final List<ShellQciDimGroup> swDimesionalObs;

  final List<ShellQciVisualOb> ewVisualObs;
  final List<ShellQciDimGroup> ewDimesionalObs;

  final List<ShellQciVisualOb> roofVisualObs;
  final List<ShellQciDimGroup> roofDimesionalObs;

  final List<ShellQciVisualOb> shellVisualObs;
  final List<ShellQciDimGroup> shellDimesionalObs;

  const ShellQciData({
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

  factory ShellQciData.fromJson(Map<String, dynamic> j) => ShellQciData(
        shortCode:          (j['short_code'] ?? '').toString(),
        ufVisualObs:        _vList(j['uf_visual_obs']),
        ufDimesionalObs:    _dList(j['uf_dimesional_obs']),
        swVisualObs:        _vList(j['sw_visual_obs']),
        swDimesionalObs:    _dList(j['sw_dimesional_obs']),
        ewVisualObs:        _vList(j['ew_visual_obs']),
        ewDimesionalObs:    _dList(j['ew_dimesional_obs']),
        roofVisualObs:      _vList(j['roof_visual_obs']),
        roofDimesionalObs:  _dList(j['roof_dimesional_obs']),
        shellVisualObs:     _vList(j['shell_visual_obs']),
        shellDimesionalObs: _dList(j['shell_dimesional_obs']),
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

  static List<ShellQciVisualOb> _vList(dynamic raw) =>
      (raw as List? ?? [])
          .map((e) => ShellQciVisualOb.fromJson(e as Map<String, dynamic>))
          .toList();

  static List<ShellQciDimGroup> _dList(dynamic raw) =>
      (raw as List? ?? [])
          .map((e) => ShellQciDimGroup.fromJson(e as Map<String, dynamic>))
          .toList();
}

// ── Visual observation row ────────────────────────────────────────────────────
//  { "description": "...", "specified_val": null,
//    "obs_val": [{ "key": "OK", "val": "1" }, ...] }

class ShellQciVisualOb {
  final String              description;
  final dynamic             specifiedVal;
  final List<ShellQciObsVal> obsVal;

  const ShellQciVisualOb({
    this.description  = '',
    this.specifiedVal,
    this.obsVal = const [],
  });

  factory ShellQciVisualOb.fromJson(Map<String, dynamic> j) => ShellQciVisualOb(
        description:  (j['description']   ?? '').toString(),
        specifiedVal: j['specified_val'],
        obsVal: (j['obs_val'] as List? ?? [])
            .map((e) => ShellQciObsVal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'description':   description,
        'specified_val': specifiedVal,
        'obs_val':       obsVal.map((e) => e.toJson()).toList(),
      };
}

// ── Dimensional group  { "innerData": [...] } ─────────────────────────────────

class ShellQciDimGroup {
  final List<ShellQciDimItem> innerData;

  const ShellQciDimGroup({this.innerData = const []});

  factory ShellQciDimGroup.fromJson(Map<String, dynamic> j) => ShellQciDimGroup(
        innerData: (j['innerData'] as List? ?? [])
            .map((e) => ShellQciDimItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'innerData': innerData.map((e) => e.toJson()).toList(),
      };
}

// ── One row inside innerData ──────────────────────────────────────────────────
//  { no, under_frame_type, metal_type_id, stage_id, visual_type_id,
//    description, id, remarks, params, radio }

class ShellQciDimItem {
  final int?                  no;
  final String                underFrameType;
  final String                metalTypeId;
  final String                stageId;
  final String                visualTypeId;
  final String                description;
  final String                id;
  final List<dynamic>         remarks;
  final List<ShellQciParam>   params;
  final String?               radio;

  const ShellQciDimItem({
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

  factory ShellQciDimItem.fromJson(Map<String, dynamic> j) => ShellQciDimItem(
        no:             j['no'] as int?,
        underFrameType: (j['under_frame_type'] ?? '').toString(),
        metalTypeId:    (j['metal_type_id']    ?? '').toString(),
        stageId:        (j['stage_id']         ?? '').toString(),
        visualTypeId:   (j['visual_type_id']   ?? '').toString(),
        description:    (j['description']      ?? '').toString(),
        id:             (j['id']               ?? '').toString(),
        remarks: List<dynamic>.from(j['remarks'] ?? []),
        params: (j['params'] as List? ?? [])
            .map((e) => ShellQciParam.fromJson(e as Map<String, dynamic>))
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

// ── Param  { value, is_visual_type_obs, lateral_params: [...] } ──────────────

class ShellQciParam {
  final String?                    value;
  final int?                       isVisualTypeObs;
  final List<ShellQciLateralParam> lateralParams;

  const ShellQciParam({
    this.value,
    this.isVisualTypeObs,
    this.lateralParams = const [],
  });

  factory ShellQciParam.fromJson(Map<String, dynamic> j) => ShellQciParam(
        value:           j['value'] as String?,
        isVisualTypeObs: j['is_visual_type_obs'] as int?,
        lateralParams: (j['lateral_params'] as List? ?? [])
            .map((e) => ShellQciLateralParam.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'value':              value,
        'is_visual_type_obs': isVisualTypeObs,
        'lateral_params':     lateralParams.map((e) => e.toJson()).toList(),
      };
}

// ── Lateral param  { value, main_label, child_val: [...] } ───────────────────

class ShellQciLateralParam {
  final String?               value;
  final String?               mainLabel;
  final List<ShellQciChildVal> childVal;

  const ShellQciLateralParam({
    this.value,
    this.mainLabel,
    this.childVal = const [],
  });

  factory ShellQciLateralParam.fromJson(Map<String, dynamic> j) =>
      ShellQciLateralParam(
        value:     j['value']      as String?,
        mainLabel: j['main_label'] as String?,
        childVal: (j['child_val'] as List? ?? [])
            .map((e) => ShellQciChildVal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'value':      value,
        'main_label': mainLabel,
        'child_val':  childVal.map((e) => e.toJson()).toList(),
      };
}

// ── Child value  { sub_child_label, sub_child_val, min_range, max_range,
//                  obs_Value, obs_val } ────────────────────────────────────────

class ShellQciChildVal {
  final String?               subChildLabel;
  final String?               subChildVal;
  final double?               minRange;
  final double?               maxRange;
  final List<dynamic>         obsValue; // obs_Value (display array)
  final List<ShellQciObsVal>  obsVal;   // obs_val  (selectable options)

  const ShellQciChildVal({
    this.subChildLabel,
    this.subChildVal,
    this.minRange,
    this.maxRange,
    this.obsValue = const [],
    this.obsVal   = const [],
  });

  factory ShellQciChildVal.fromJson(Map<String, dynamic> j) => ShellQciChildVal(
        subChildLabel: j['sub_child_label'] as String?,
        subChildVal:   j['sub_child_val']   as String?,
        minRange:      _toDouble(j['min_range']),
        maxRange:      _toDouble(j['max_range']),
        obsValue: List<dynamic>.from(j['obs_Value'] ?? []),
        obsVal: (j['obs_val'] as List? ?? [])
            .map((e) => ShellQciObsVal.fromJson(e as Map<String, dynamic>))
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

// ── obs_val item  { "key": "OK", "val": "1" } ────────────────────────────────
//   key = display label shown in UI
//   val = value stored / sent to API

class ShellQciObsVal {
  final String  key; // e.g. "OK", "Not OK", "Not Done"
  final dynamic val; // e.g. 1, "1", "2"

  const ShellQciObsVal({required this.key, this.val});

  factory ShellQciObsVal.fromJson(Map<String, dynamic> j) => ShellQciObsVal(
        key: (j['key'] ?? '').toString(),
        val: j['val'],
      );

  Map<String, dynamic> toJson() => {'key': key, 'val': val};
}
