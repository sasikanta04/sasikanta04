/// One option inside a radio / dropdown field.
class SaQciObservationOption {
  final String value; // stored value  — obs_val[].val
  final String label; // display text  — obs_val[].key

  const SaQciObservationOption({required this.value, required this.label});
}

/// One input field inside an observation item.
///   options.isEmpty  → free-text / numeric input  (dimensional measurement)
///   options.isNotEmpty → radio / dropdown select  (visual pass/fail)
class SaQciObservationField {
  final String label;
  final List<SaQciObservationOption> options;
  final double? minRange;
  final double? maxRange;

  const SaQciObservationField({
    required this.label,
    this.options = const [],
    this.minRange,
    this.maxRange,
  });
}

/// One row in the observation table.
class SaQciObservationItem {
  final String id;
  final String description;
  final List<SaQciObservationField> fields;

  const SaQciObservationItem({
    required this.id,
    required this.description,
    required this.fields,
  });
}

/// Root UI model.
///   visualByModule      — keyed by 'uf' | 'sw' | 'ew' | 'roof' | 'shell'
///   dimensionalByModule — same keys
///
/// Parses the [Data.toJson()] structure returned by the ShellQciForm API
/// and stored in Hive via SaQciAllFormsService.
class SaQciFormUiModel {
  final String shortCode;
  final Map<String, List<SaQciObservationItem>> visualByModule;
  final Map<String, List<SaQciObservationItem>> dimensionalByModule;

  const SaQciFormUiModel({
    this.shortCode = '',
    required this.visualByModule,
    required this.dimensionalByModule,
  });

  /// [json] must be the inner `data` map from the API —
  ///   { "short_code": "...", "uf_visual_obs": [...], "uf_dimesional_obs": [...], ... }
  factory SaQciFormUiModel.fromJson(Map<String, dynamic> json) {
    return SaQciFormUiModel(
      shortCode: (json['short_code'] ?? '').toString(),
      visualByModule: {
        'uf':    _parseVisual(json['uf_visual_obs'],    'uf'),
        'sw':    _parseVisual(json['sw_visual_obs'],    'sw'),
        'ew':    _parseVisual(json['ew_visual_obs'],    'ew'),
        'roof':  _parseVisual(json['roof_visual_obs'],  'roof'),
        'shell': _parseVisual(json['shell_visual_obs'], 'shell'),
      },
      dimensionalByModule: {
        'uf':    _parseDim(json['uf_dimesional_obs']),
        'sw':    _parseDim(json['sw_dimesional_obs']),
        'ew':    _parseDim(json['ew_dimesional_obs']),
        'roof':  _parseDim(json['roof_dimesional_obs']),
        'shell': _parseDim(json['shell_dimesional_obs']),
      },
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  /// Converts obs_val list → SaQciObservationOption list.
  /// API sends: [{"key": "OK", "val": "1"}, ...]
  /// key = display label, val = stored value.
  static List<SaQciObservationOption> _parseObsVal(dynamic raw) {
    if (raw == null) return const [];
    return (raw as List).map((o) {
      final m = o as Map;
      final key = (m['key'] ?? '').toString();
      final val = (m['val'] ?? m['value'] ?? key).toString();
      return SaQciObservationOption(value: val, label: key);
    }).toList();
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  /// Parses uf_visual_obs / sw_visual_obs / … list.
  /// Each entry: { description, obs_val: [{key, val}] }
  static List<SaQciObservationItem> _parseVisual(dynamic raw, String moduleKey) {
    if (raw == null) return const [];
    final list = raw as List;
    final result = <SaQciObservationItem>[];
    for (var i = 0; i < list.length; i++) {
      final m = Map<String, dynamic>.from(list[i] as Map);
      final desc    = (m['description'] ?? '').toString();
      final options = _parseObsVal(m['obs_val']);
      result.add(SaQciObservationItem(
        id:          '${moduleKey}_vis_$i',
        description: desc,
        fields: [
          SaQciObservationField(label: desc, options: options),
        ],
      ));
    }
    return result;
  }

  /// Parses uf_dimesional_obs / sw_dimesional_obs / … list.
  /// Structure: [ { innerData: [ { id, description, params: [ { lateral_params: [ { child_val: [...] } ] } ] } ] } ]
  static List<SaQciObservationItem> _parseDim(dynamic raw) {
    if (raw == null) return const [];
    final outerList = raw as List;
    final result = <SaQciObservationItem>[];

    for (final outer in outerList) {
      final outerMap  = Map<String, dynamic>.from(outer as Map);
      final innerData = outerMap['innerData'] as List? ?? [];

      for (final inner in innerData) {
        final m    = Map<String, dynamic>.from(inner as Map);
        final id   = (m['id'] ?? '').toString();
        final desc = (m['description'] ?? '').toString();

        final fields  = <SaQciObservationField>[];
        final params  = m['params'] as List? ?? [];

        for (final param in params) {
          final pMap         = param as Map;
          final lateralList  = pMap['lateral_params'] as List? ?? [];

          for (final lp in lateralList) {
            final lpMap    = lp as Map;
            final mainLabel = (lpMap['main_label'] ?? '').toString();
            final childVal  = lpMap['child_val'] as List? ?? [];

            for (final cv in childVal) {
              final cvMap    = Map<String, dynamic>.from(cv as Map);
              final subLabel = (cvMap['sub_child_label'] ?? cvMap['sub_child_val'] ?? '').toString();
              final label    = [mainLabel, subLabel].where((s) => s.isNotEmpty).join(' — ');
              final options  = _parseObsVal(cvMap['obs_val']);

              fields.add(SaQciObservationField(
                label:    label.isEmpty ? desc : label,
                options:  options,
                minRange: _toDouble(cvMap['min_range']),
                maxRange: _toDouble(cvMap['max_range']),
              ));
            }
          }
        }

        if (fields.isNotEmpty) {
          result.add(SaQciObservationItem(id: id, description: desc, fields: fields));
        }
      }
    }
    return result;
  }
}
