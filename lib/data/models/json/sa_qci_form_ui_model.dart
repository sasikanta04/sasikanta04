class SaQciFormUiModel {
  final String shortCode;
  final Map<String, List<SaQciObservationItem>> dimensionalByModule;
  final Map<String, List<SaQciObservationItem>> visualByModule;

  const SaQciFormUiModel({
    required this.shortCode,
    required this.dimensionalByModule,
    required this.visualByModule,
  });

  // root must be: { "data": { "short_code": "...", "uf_visual_obs": [...], ... } }
  // Pass cached.data wrapped: {'data': cached.data}
  factory SaQciFormUiModel.fromJson(Map<String, dynamic> root) {
    final data = root['data'];
    if (data is! Map<String, dynamic>) {
      return const SaQciFormUiModel(
        shortCode: '',
        dimensionalByModule: {},
        visualByModule: {},
      );
    }

    List<SaQciObservationItem> parseObsList(
      String key, {
      required String moduleKey,
    }) {
      final rawList = data[key];
      if (rawList is! List) return const <SaQciObservationItem>[];
      final items = <SaQciObservationItem>[];
      for (var i = 0; i < rawList.length; i++) {
        final block = rawList[i];
        if (block is! Map<String, dynamic>) continue;

        final innerData = block['innerData'];
        if (innerData is List) {
          for (final row in innerData) {
            if (row is! Map<String, dynamic>) continue;
            items.add(SaQciObservationItem.fromJson(row));
          }
          continue;
        }

        if (block.containsKey('description')) {
          items.add(
            SaQciObservationItem.fromSimplifiedVisualJson(
              block,
              moduleKey: moduleKey,
              index: i,
            ),
          );
        }
      }
      return items;
    }

    const modules = <String>['uf', 'sw', 'ew', 'roof', 'shell'];
    final dimMap = <String, List<SaQciObservationItem>>{};
    final visMap = <String, List<SaQciObservationItem>>{};

    for (final module in modules) {
      dimMap[module] = parseObsList('${module}_dimesional_obs', moduleKey: module);
      visMap[module] = parseObsList('${module}_visual_obs',     moduleKey: module);
    }

    return SaQciFormUiModel(
      shortCode:          (data['short_code'] ?? '').toString(),
      dimensionalByModule: dimMap,
      visualByModule:      visMap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class SaQciObservationItem {
  final int    no;
  final String id;
  final String description;
  final bool   isVisualTypeObs;
  final List<SaQciObservationField> fields;

  const SaQciObservationItem({
    required this.no,
    required this.id,
    required this.description,
    required this.isVisualTypeObs,
    required this.fields,
  });

  // Dimensional row — comes from innerData[]
  factory SaQciObservationItem.fromJson(Map<String, dynamic> json) {
    final fields = <SaQciObservationField>[];
    final params = json['params'];
    var isVisual = false;

    if (params is List) {
      for (var paramIndex = 0; paramIndex < params.length; paramIndex++) {
        final param = params[paramIndex];
        if (param is! Map<String, dynamic>) continue;

        final isVisualRaw = (param['is_visual_type_obs'] ?? 0).toString();
        if (isVisualRaw == '1') isVisual = true;

        final lateralParams = param['lateral_params'];
        if (lateralParams is! List) continue;

        final paramApiValue = (param['value'] ?? '').toString();

        for (var lateralIndex = 0;
            lateralIndex < lateralParams.length;
            lateralIndex++) {
          final lateral = lateralParams[lateralIndex];
          if (lateral is! Map<String, dynamic>) continue;

          final lateralApiValue = (lateral['value'] ?? '').toString();
          final childVals       = lateral['child_val'];
          if (childVals is! List) continue;

          for (var i = 0; i < childVals.length; i++) {
            final child = childVals[i];
            if (child is! Map<String, dynamic>) continue;
            fields.add(
              SaQciObservationField.fromJson(
                json:                child,
                defaultLabel:        lateralApiValue,
                fallbackIndex:       i,
                paramIndex:          paramIndex,
                lateralIndex:        lateralIndex,
                paramApiValue:       paramApiValue,
                lateralApiValue:     lateralApiValue,
                childIndexInLateral: i,
              ),
            );
          }
        }
      }
    }

    return SaQciObservationItem(
      no:              (json['no'] as num?)?.toInt() ?? 0,
      id:              (json['id'] ?? '').toString(),
      description:     (json['description'] ?? '').toString(),
      isVisualTypeObs: isVisual,
      fields:          fields,
    );
  }

  // Visual row — flat shape: { "description": "...", "obs_val": [{key, val}] }
  factory SaQciObservationItem.fromSimplifiedVisualJson(
    Map<String, dynamic> json, {
    required String moduleKey,
    required int    index,
  }) {
    final description = (json['description'] ?? '').toString();

    final options = <String>[];
    final rawObsVals = json['obs_val'];
    if (rawObsVals is List) {
      for (final option in rawObsVals) {
        if (option is! Map<String, dynamic>) continue;
        final text = (option['key'] ?? '').toString().trim();
        if (text.isNotEmpty) options.add(text);
      }
    }

    return SaQciObservationItem(
      no:              index + 1,
      id:              '${moduleKey}_vis_${index}_${description.hashCode}',
      description:     description,
      isVisualTypeObs: true,
      fields: [
        SaQciObservationField(
          label:               '',
          specifiedValue:      '',
          minRange:            null,
          maxRange:            null,
          options:             options,
          paramIndex:          null,
          lateralIndex:        null,
          paramApiValue:       null,
          lateralApiValue:     null,
          childIndexInLateral: 0,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class SaQciObservationField {
  final String  label;
  final String  specifiedValue;
  final double? minRange;
  final double? maxRange;
  final List<String> options; // empty → numeric text input; non-empty → radio/select

  final int?    paramIndex;
  final int?    lateralIndex;
  final String? paramApiValue;
  final String? lateralApiValue;
  final int     childIndexInLateral;

  const SaQciObservationField({
    required this.label,
    required this.specifiedValue,
    required this.minRange,
    required this.maxRange,
    required this.options,
    this.paramIndex,
    this.lateralIndex,
    this.paramApiValue,
    this.lateralApiValue,
    this.childIndexInLateral = 0,
  });

  factory SaQciObservationField.fromJson({
    required Map<String, dynamic> json,
    required String defaultLabel,
    required int    fallbackIndex,
    int?    paramIndex,
    int?    lateralIndex,
    String? paramApiValue,
    String? lateralApiValue,
    int     childIndexInLateral = 0,
  }) {
    final obsVals = <String>[];
    final rawObsVals = json['obs_val'];
    if (rawObsVals is List) {
      for (final option in rawObsVals) {
        if (option is! Map<String, dynamic>) continue;
        final text = (option['key'] ?? '').toString().trim();
        if (text.isNotEmpty) obsVals.add(text);
      }
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num)  return value.toDouble();
      return double.tryParse(value.toString().trim());
    }

    final subChildLabel  = (json['sub_child_label'] ?? '').toString().trim();
    final lateralDefault = defaultLabel.trim();
    final label = subChildLabel.isNotEmpty
        ? subChildLabel
        : (lateralDefault.isNotEmpty ? lateralDefault : '');

    return SaQciObservationField(
      label:               label,
      specifiedValue:      (json['sub_child_val'] ?? '').toString(),
      minRange:            parseDouble(json['min_range']),
      maxRange:            parseDouble(json['max_range']),
      options:             obsVals,
      paramIndex:          paramIndex,
      lateralIndex:        lateralIndex,
      paramApiValue:       paramApiValue,
      lateralApiValue:     lateralApiValue,
      childIndexInLateral: childIndexInLateral,
    );
  }
}
